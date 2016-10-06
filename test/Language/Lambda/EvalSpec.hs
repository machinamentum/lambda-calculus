module Language.Lambda.EvalSpec where

import Test.Hspec

import Language.Lambda.Eval
import Language.Lambda.Expression

spec :: Spec
spec = do
  describe "evalExpr" $ do
    it "beta reduces" $ do
      let expr = App (Abs "x" (Var "x")) (Var "z")
      evalExpr expr `shouldBe` Var "z"

    it "reduces multiple applications" $ do
      let expr = App (App (Abs "f" (Abs "x" (App (Var "f") (Var "x")))) (Var "g")) (Var "y")
      evalExpr expr `shouldBe` App (Var "g") (Var "y")

    it "reduces inner redexes" $ do
      let expr = Abs "x" (App (Abs "y" (Var "y")) (Var "x"))
      evalExpr expr `shouldBe` Abs "x" (Var "x")

  describe "betaReduce" $ do
    it "reduces simple applications" $ do
      let e1 = Abs "x" (Var "x")
          e2 = (Var "y")
      betaReduce e1 e2 `shouldBe` Var "y"

    it "reduces nested abstractions" $ do
      let e1 = Abs "x" (Abs "y" (Var "x"))
          e2 = Var "z"
      betaReduce e1 e2 `shouldBe` Abs "y" (Var "z")

    it "reduces inner applications" $ do
      let e1 = Abs "f" (App (Var "f") (Var "x"))
          e2 = Var "g"
      betaReduce e1 e2 `shouldBe` App (Var "g") (Var "x")

    it "does not reduce unreducible expression" $ do
      let e1 = Var "x"
          e2 = Var "y"
      betaReduce e1 e2 `shouldBe` App (Var "x") (Var "y")

    it "does not reduce irreducible chained applications" $ do
      let e1 = App (Var "x") (Var "y")
          e2 = Var "z"
      betaReduce e1 e2 `shouldBe` App (App (Var "x") (Var "y")) (Var "z")

    it "does not sub shadowed bindings" $ do
      let e1 = Abs "x" (Abs "x" (Var "x"))
          e2 = Var "z"
      betaReduce e1 e2 `shouldBe` Abs "x" (Var "x")


  describe "alphaConvert" $ do
    it "alpha converts simple expressions" $ do
      let freeVars = ["x"]
          expr = Abs "x" (Var "x")
          uniques = ["y"]
      alphaConvert uniques freeVars expr `shouldBe` Abs "y" (Var "y")
  
    it "avoids captures" $ do
      let freeVars = ["x"]
          expr = Abs "x" (Var "x")
          uniques = ["x", "y"]
      alphaConvert uniques freeVars expr `shouldBe` Abs "y" (Var "y")
