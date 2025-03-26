{-# LANGUAGE ViewPatterns #-}

import Data.List (genericLength)
import Test.Hspec
import Test.Hspec.Core.QuickCheck
import Test.QuickCheck

import WordCount (countElementsInString, WCOutputs(..))

main :: IO ()
main = hspec $ parallel $ modifyMaxSuccess (const 10000) $ modifyMaxSize (const 1000) $ do
    it "Chars counting" $ property $
      \(getASCIIString -> str) -> do
        output <- countElementsInString str
        (charCount . snd) output `shouldBe` genericLength str
    it "Words counting" $ property $
      \(getASCIIString -> str) -> do
        output <- countElementsInString str
        (wordsCount . snd) output `shouldBe` genericLength (words str)
    it "Counts lines" $ property $
      \(getASCIIString -> str) -> do
        output <- countElementsInString str
        (lineCount . snd) output `shouldBe` genericLength (filter (== '\n') str)
