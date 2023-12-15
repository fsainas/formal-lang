import Lang.Ast
import Mathlib.Data.Finset.Basic


/-!
# Static checker

This module focuses on static properties of a program. Meaning, the analysis
that can be performed on source code without actually evaluating it.
-/

/-! ## Definitions -/

/-- Variables is a set of currently defined variable names. -/
abbrev Variables := Finset Name

/-- Returns true if the expression is well-formed. -/
def typeCheckExpr (expr : Expr) (vars : Variables) : Bool := match expr with
  | Expr.true => Bool.true
  | Expr.false => Bool.true
  | Expr.nand left right => (typeCheckExpr left vars) && (typeCheckExpr right vars)
  | Expr.ident name => name ∈ vars
  -- | Expr.ref of => Bool.true
  -- | Expr.deref of => Bool.true

-- def typeCheckStmt (stmt : Stmt) (env : Env) : Bool := match stmt with
--   | Stmt.decl name value =>  (AList.lookup name env).isNone && (typeCheckExpr value env)
--   | Stmt.assign target value => (AList.lookup target env).isSome && (typeCheckExpr value env)
--   | Stmt.conditional condition body => (typeCheckExpr condition env) && (typeCheckStmt body env)

/-! ## Properties -/

/-- An expression is closed if accessed variables exist. -/
def isClosedExpr (expr : Expr) (vars : Variables) : Bool := match expr with
  | Expr.true => Bool.true
  | Expr.false => Bool.true
  | Expr.nand left right => (isClosedExpr left vars) && (isClosedExpr right vars)
  | Expr.ident name => name ∈ vars

/-! ## Theorems -/

/-- If Expr.nand is type checked, then lhs is type checked too. -/
lemma typeCheckExpr_nandLeft (h : typeCheckExpr (Expr.nand left right) vars) : typeCheckExpr left vars := by
  unfold typeCheckExpr at h
  simp [Bool.coe_and_iff] at h
  apply And.left at h
  exact h

/-- If Expr.nand is type checked, then rhs is type checked too. -/
lemma typeCheckExpr_nandRight (h : typeCheckExpr (Expr.nand left right) vars) : typeCheckExpr right vars := by
  unfold typeCheckExpr at h
  simp [Bool.coe_and_iff] at h
  apply And.right at h
  exact h

/-- If Expr.ident is type checked, then the name exists in the `vars` set. -/
lemma typeCheckExpr_ident (h : typeCheckExpr (Expr.ident name) vars) : name ∈ vars := by
  unfold typeCheckExpr at h
  exact (Bool.coe_decide (name ∈ vars)).mp h

/-- Given that the type checker accepts the expression, we know that the expression is closed. -/
theorem typeCheckExpr_isClosedExpr (expr : Expr) (h : (typeCheckExpr expr vars)) : (isClosedExpr expr vars) := match expr with
  | Expr.true => by
    apply h
  | Expr.false => by
    apply h
  | Expr.nand left right => by
    unfold typeCheckExpr at h
    unfold isClosedExpr
    simp [Bool.coe_and_iff] at h
    simp [Bool.coe_and_iff]
    have l := And.left h
    have r := And.right h

    have lp := by apply (typeCheckExpr_isClosedExpr left l)
    have rp := by apply (typeCheckExpr_isClosedExpr right r)
    exact ⟨lp, rp⟩
  | Expr.ident _ => by
    apply h
