module Test.Main where

import Prelude

import Bonjiri as B
import Calpis as C
import Calpis.Impl.Node (nodeFetch)
import Data.String (null)
import Effect (Effect)
import Effect.Exception (error, throwException)
import Foreign.Object as Object
import Test.Spec.Assertions (shouldContain, shouldEqual)

fetch :: C.Fetch
fetch = C.fetch nodeFetch

main :: Effect Unit
main = do
  let fetchSpec = fetch (C.URL "https://www.google.com") C.defaultFetchOptions
  let textSpec = B.chain C.text fetchSpec
  let spec = { response: _, text: _ } <$> fetchSpec <*> textSpec
  B.run
    do \_ -> throwException (error "Should spec should not fail")
    do
      \{ response, text } -> do
        let code = C.statusCode response
        code `shouldEqual` 200
        null text `shouldEqual` false
        let headers = C.headers response
        Object.keys headers `shouldContain` "content-type"
        Object.keys headers `shouldContain` "content-encoding"
    spec
