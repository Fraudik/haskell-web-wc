module WordCount (foldWith, foldCountElements, printSelecttedOutput, WCOutputs(..)) where

import Streamly.Data.Fold (Fold)
import Data.Bits
import qualified Streamly.Data.Stream as Stream
import Data.Word (Word8)
import qualified Streamly.Data.Fold as Fold
import qualified Streamly.FileSystem.File as File
import Data.Function ((&))

foldWith :: Fold IO Word8 a -> String -> IO a
foldWith f file =
  File.read file
  & Stream.fold f

data WCOutputs =
    WCOutputs {
             bytesCount :: !Int
           , charCount :: !Int
           , lineCount :: !Int
           }
    deriving (Show)

instance Semigroup WCOutputs where
  (WCOutputs a b c) <> (WCOutputs a' b' c') = WCOutputs (a + a') (b + b') (c + c')

instance Monoid WCOutputs where
  mempty = WCOutputs 0 0 0

countElements :: Word8 -> WCOutputs
countElements c  =
     WCOutputs {
                 bytesCount = 1
               , charCount = if isContinuationByte then 0 else 1
               , lineCount = if c == 10 then 1 else 0
               }
      where
        isContinuationByte = (c .&. 0xC0) == 0x80

foldCountElements :: Fold IO Word8 WCOutputs
foldCountElements = Fold.foldl' (\a b -> a <> countElements b) mempty

printSelecttedOutput :: WCOutputs -> String
printSelecttedOutput output = show (lineCount output) ++ " " ++ show (charCount output) ++ " " ++ show (bytesCount output)
