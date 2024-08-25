{-# LANGUAGE DeriveGeneric #-} -- (2)

module Main where

-- import MonadRandom
import Control.Monad.Random
import Control.Exception (catch)
import System.IO.Error (isDoesNotExistError)
import GHC.IO.Exception
import Lib
import System.IO
import System.Process

import qualified Data.ByteString.Char8 as BS
import qualified Data.Yaml as Y
import GHC.Generics
import Data.Aeson

data Cred = Cred { example :: String, other :: String } deriving (Show, Generic) -- (1,2)
instance FromJSON Cred -- (3)

getRandomMaidIndex :: (MonadRandom m) => m Int
getRandomMaidIndex = do
  let n = length maids - 1
  getRandomR (0, n)

getRandomMaid = do
  n <- getRandomMaidIndex
  return (maids !! n)

-- FIXME REFACTOR error handling ._.

globSufVid = "./*.mpv ./*.webm ./*.mp4 ./*.mov ./*.mkv ./*.ts ./*.m3u8 "

globSufMus = "./*.mp3 ./*.ogg ./*.m4a ./*.wav ./*.flac ./*.opus ./*.mid "

globSufPic = "./*.png ./*.jpg ./*.jpeg ./*.webp ./*.gif ./*.svg ./*.cr3 ./*.xcf ./*.bmp"

globSufBook = "./*.pdf ./*.PDF ./*.epub ./*.mobi ./*.azw3 ./*.djvu "

globSufGame = "./*.z64 ./*.bps "

globSufPlaintext = "./*.txt ./*.org ./*.bbl ./*.tex ./*.ods ./*.md ./*.csv "

globSufCode = "./*.fish ./*.i90 ./*.i03 ./*.i95 ./*.f ./*.for ./*.f03 ./*.f90 ./*.f95 ./*.yaml ./*.yml ./*.cs ./*.nix ./*.json ./*.rs ./*.jl ./*.py ./*.pl ./*.R ./*.c ./*.cpp ./*.h ./*.sh ./*.v ./*.css ./*.guile ./*.js ./*.asm ./*.acsm ./*.o ./*.s ./*.rkt ./*.lisp ./*.lsp ./*.hs ./*.hi ./*.fsi ./*.fsx ./*.fs ./*.el ./*.zig ./*.bash ./*.r"

globSufSecret = "./*.asc ./*.gpg "

globSufWebsite = "./*.html ./*.htm "

globSufExecutable = "./*.out "

globSufBlender = "./*.blend1 "

makeDir :: [Char] -> IO ExitCode
makeDir dir = system $ "mkdir -p \"" ++ dir ++ "\""

declutter :: [Char] -> [Char] -> IO ExitCode
declutter glob targetDir = system $ "yes n | \\mv --backup=numbered -i -- " ++ glob ++ " \"" ++ targetDir ++ "\" 2> /dev/null"

createUnsrtXDG :: IO GHC.IO.Exception.ExitCode
createUnsrtXDG = do
  _ <- makeDir "$XDG_VIDEOS_DIR/unsrt"
  _ <- makeDir "$XDG_MUSIC_DIR/unsrt"
  _ <- makeDir "$XDG_PICTURES_DIR/unsrt"
  _ <- makeDir "$XDG_DOCUMENTS_DIR/unsrt"
  _ <- makeDir "$XDG_DOCUMENTS_DIR/src/unsrt"
  makeDir "$XDG_DOCUMENTS_DIR/gpg-keys"

createUnsrtCustom :: IO GHC.IO.Exception.ExitCode
createUnsrtCustom = do
  _ <- makeDir "$HOME/med/bok/unsrt" -- Books
  _ <- makeDir "$HOME/med/gms/unsrt" -- Video games (emulation)
  _ <- makeDir "$HOME/med/html/unsrt"
  _ <- makeDir "$HOME/sys/elf/unsrt"
  makeDir "$XDG_DOCUMENTS_DIR/blender"

performDeclutter :: IO GHC.IO.Exception.ExitCode
performDeclutter = do
  _ <- declutter globSufVid "$XDG_VIDEOS_DIR/unsrt"
  _ <- declutter globSufMus "$XDG_MUSIC_DIR/unsrt"
  _ <- declutter globSufPic "$XDG_PICTURES_DIR/unsrt"
  _ <- declutter globSufBook "$HOME/med/bok/unsrt"
  _ <- declutter globSufGame "$HOME/med/gms/unsrt"
  _ <- declutter globSufPlaintext "$XDG_DOCUMENTS_DIR/unsrt"
  _ <- declutter globSufCode "$XDG_DOCUMENTS_DIR/src/unsrt"
  _ <- declutter globSufSecret "$XDG_DOCUMENTS_DIR/gpg-keys"
  _ <- declutter globSufWebsite "$HOME/med/html/unsrt"
  _ <- declutter globSufExecutable "$HOME/sys/elf/unsrt"
  declutter globSufBlender "$XDG_DOCUMENTS_DIR/gpg-keys"

performCleanup :: IO GHC.IO.Exception.ExitCode
performCleanup = do
  _ <- system "rm wget-log 2>/dev/null"
  system "rm wget-log.* 2>/dev/null"

safeReadFile :: FilePath -> IO BS.ByteString
safeReadFile path = (BS.readFile path) `catch` handleDoesNotExist
  where
    handleDoesNotExist e
      | isDoesNotExistError e = return BS.empty
      | otherwise = ioError e

main :: IO ()
main = do
  content <- safeReadFile "config.yaml" -- (4)
  let parsedContent = Y.decode content :: Maybe Cred -- (5)
  case parsedContent of
    Nothing -> putStrLn "[-] no config values found"
    (Just (Cred u p)) -> putStrLn ("[+] example: " ++ u ++ ", other: " ++ p)
  maid <- getRandomMaid
  putStrLn maid
  putStrLn "[+] !!!Cleaning Time!!!"
  hFlush stdout
  putStrLn "[*] Creating unsrt folder for xdgdirs"
  hFlush stdout
  _ <- createUnsrtXDG
  putStrLn "[*] Creating unsrt folder for custom dirs"
  hFlush stdout
  _ <- createUnsrtCustom
  putStrLn "[*] Declutter current dir"
  hFlush stdout
  _ <- performDeclutter
  putStrLn "[*] Remove log files"
  hFlush stdout
  _ <- performCleanup
  putStrLn "[+] DONE!"
