module WordCount (foldWith, foldCountElements, printSelecttedOutput) where

import Streamly.Data.Fold (Fold)
import qualified Streamly.Data.Stream as Stream
import qualified Streamly.Data.Fold as Fold
import qualified Streamly.FileSystem.File as File
import Data.Function ((&))
import Data.Char (ord)
import qualified Streamly.Unicode.Stream as Stream

isSpace :: Char -> Bool
isSpace c = uc == 0x20 || uc - 0x9 <= 4
  where uc = fromIntegral (ord c) :: Word

data WCOutputs =
    WCOutputs {
             charCount :: !Int
           , wordsCount :: !Int
           , lineCount :: !Int
           , isSpaceChar :: !Bool
           }
    deriving (Show)

count :: WCOutputs -> Char -> WCOutputs
count (WCOutputs charsAmount wordsAmount linesAmount wasSpace) char =
    let newLinesAmount = if char == '\n' then linesAmount + 1 else linesAmount
        (newWordsAmount, isSpaceChar) = if isSpace char then (wordsAmount, True)
            else (if wasSpace then wordsAmount + 1 else wordsAmount, False)
    in WCOutputs (charsAmount + 1) newWordsAmount newLinesAmount isSpaceChar

foldWith :: Fold IO Char a -> String -> IO a
foldWith f file =
      File.read file
    & Stream.decodeUtf8
    & Stream.fold f
    
foldCountElements :: Fold IO Char WCOutputs
foldCountElements = Fold.foldl' count (WCOutputs 0 0 0 True)

printSelecttedOutput :: WCOutputs -> String
printSelecttedOutput output = show (lineCount output) ++ " " ++ show (wordsCount output) ++ " " ++ show (charCount output)
