module Lib (run)
where
import Network.HTTP       (simpleHTTP, getResponseBody, getRequest) 
import System.Environment (getArgs)
import System.Directory   (createDirectoryIfMissing)
import System.Process     (callCommand)
import System.FilePath    (pathSeparator)
import Data.List          ((\\), sort)
import Text.Regex.Posix   ((=~))
import Text.HTML.TagSoup  (Tag(..), parseTags, (~==), fromAttrib)

data Anchor = Anchor { anchorHref  :: String
                     , anchorTitle :: String
                     , anchorClass :: String
                     } deriving (Show, Read, Eq)

data Episode = Episode { episodeNumber :: Int
                       , episodeName   :: String
                       , episodeUrl    :: String 
                       } deriving (Show, Read, Eq)

instance Ord Episode where
    (Episode n1 _ _) <= (Episode n2 _ _) = n1 <= n2

createAnchor :: Tag String -> Anchor
createAnchor tag = Anchor hs ts cs
    where hs = fromAttrib "href"  tag
          ts = fromAttrib "title" tag
          cs = fromAttrib "class" tag

isEpisodeAnchor :: Anchor -> Bool
isEpisodeAnchor (Anchor _ _ cs) = cs =~ "episode"

createEpisode :: Anchor -> Episode
createEpisode (Anchor hs _ _) = Episode n ns hs
    where ns = hs =~ "episode-[0-9]+"
          n = read (ns =~ "[0-9]+" :: String)

getEpisodeList :: String -> FilePath -> IO [Episode]
getEpisodeList url animeName = do
    let ns = animeName ++ "/episode-list"
    html <- getResponseBody =<< simpleHTTP (getRequest url)
    let ts =  filter (~== "<a>") $ parseTags html
        as = filter isEpisodeAnchor $ map createAnchor ts
        es = sort $ map createEpisode as
    return es

filterEpisodes :: String -> [Episode] -> [Episode]
filterEpisodes ns es = filter fn es
    where n2 = read ns
          fn = \(Episode n1 _ _) -> n1 >= n2

openStream :: String -> String -> String -> Bool -> Episode -> IO ()
openStream username password animeName download (Episode _ name url) = do
    let us = "--crunchyroll-username=" ++ username
        ps = "--crunchyroll-password=" ++ password
        ds = if download
                then "-o " ++ animeName ++ [pathSeparator] ++ name ++ ".flv"
                else ""
        qs = "best"
        ls = "http://www.crunchyroll.com" ++ url
        cmd = unwords $ filter (not . null) $ "livestreamer":us:ps:ds:ls:qs:[]
    putStrLn cmd 
    callCommand cmd

run :: IO ()
run = do
    [username, password, url, episode, dl] <- getArgs
    let animeName = url \\ "http://www.crunchyroll.com/"        
        download = read dl
    createDirectoryIfMissing True animeName
    es <- return . filterEpisodes episode =<< getEpisodeList url animeName
    mapM_ (openStream username password animeName download) es