module WordCount (countElements, printSelecttedOutput) where

import Streamly.Data.Fold (Fold)
import qualified Streamly.Data.Stream as Stream
import qualified Streamly.Data.Fold as Fold
import qualified Streamly.FileSystem.File as File
import Data.Function ((&))
import Data.Char (ord)
import Data.Word (Word8)
import qualified Streamly.Unicode.Stream as Stream
import Streamly.Data.Array (Array)
import qualified Streamly.Data.Stream.Prelude as Stream
import GHC.Conc (numCapabilities)
import qualified Streamly.Data.Array as Array
import Data.Char (chr)

isSpace :: Char -> Bool
isSpace c = uc == 32 || uc - 0x9 <= 4 || uc == 0xa0
  where
    uc = fromIntegral (ord c) :: Word

data WCOutputs =
    WCOutputs {
             charCount :: !Int
           , wordsCount :: !Int
           , lineCount :: !Int
           , isSpaceChar :: !Bool
           }
    deriving (Show)

processChar :: WCOutputs -> Char -> WCOutputs
processChar (WCOutputs charsAmount wordsAmount linesAmount wasSpace) char =
    let newLinesAmount = if char == '\n' then linesAmount + 1 else linesAmount
        (newWordsAmount, isSpaceChar') = if isSpace char then (wordsAmount, True)
                                         else (if wasSpace then wordsAmount + 1 else wordsAmount, False)
    in WCOutputs (charsAmount + 1) newWordsAmount newLinesAmount isSpaceChar'

processChunk :: Array Word8 -> IO (Bool, WCOutputs)
processChunk chunk = do
    let firstChar = Array.getIndex 0 chunk
    case firstChar of
        Just x -> do
            output <- countChunkElements chunk
            return (isSpace (chr (fromIntegral x)), output)
        Nothing -> return (False, WCOutputs 0 0 0 True)
    where
      countChunkElements chunk' = 
              Array.read chunk'
            & Stream.decodeUtf8
            & Stream.fold (Fold.foldl' processChar (WCOutputs 0 0 0 True))

combineChunkOutputs :: (Bool, WCOutputs) -> (Bool, WCOutputs) -> (Bool, WCOutputs)
combineChunkOutputs (fstBeginsWithSpace, WCOutputs fstLines fstWords fstChars fstEndsWithSpace) (sndBeginsWithSpace, WCOutputs sndLines sndWords sndChars sndEndsWithSpace) =
    -- For correctly processing multiple following spaces and first/last words
    let combinedWordCount = if not fstEndsWithSpace && not sndBeginsWithSpace
                            then fstWords + sndWords - 1
                            else fstWords + sndWords
    in (fstBeginsWithSpace, WCOutputs (fstLines + sndLines) combinedWordCount (fstChars + sndChars) sndEndsWithSpace)

foldChunks :: Fold IO (Bool, WCOutputs) (Bool, WCOutputs)
foldChunks = Fold.foldl' combineChunkOutputs (False, WCOutputs 0 0 0 True)

countElements :: String -> IO (Bool, WCOutputs)
countElements file = do
      File.readChunks file
    & Stream.parMapM (Stream.maxThreads numCapabilities . Stream.ordered True) processChunk
    & Stream.fold foldChunks

printSelecttedOutput :: (Bool, WCOutputs) -> String
printSelecttedOutput output = show (lineCount . snd $ output) ++ " " ++ show (wordsCount . snd $ output) ++ " " ++ show (charCount . snd $ output)
