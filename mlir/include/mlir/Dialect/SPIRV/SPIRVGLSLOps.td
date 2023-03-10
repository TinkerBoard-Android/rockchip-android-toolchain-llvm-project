//===- SPIRVGLSLOps.td - GLSL extended insts spec file -----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This is the op definition spec of GLSL extension ops.
//
//===----------------------------------------------------------------------===//

#ifndef SPIRV_GLSL_OPS
#define SPIRV_GLSL_OPS

include "mlir/Dialect/SPIRV/SPIRVBase.td"
include "mlir/Interfaces/SideEffectInterfaces.td"

//===----------------------------------------------------------------------===//
// SPIR-V GLSL 4.50 opcode specification.
//===----------------------------------------------------------------------===//

// Base class for all GLSL ops.
class SPV_GLSLOp<string mnemonic, int opcode, list<OpTrait> traits = []> :
  SPV_ExtInstOp<mnemonic, "GLSL", "GLSL.std.450", opcode, traits>;

// Base class for GLSL unary ops.
class SPV_GLSLUnaryOp<string mnemonic, int opcode, Type resultType,
                      Type operandType, list<OpTrait> traits = []> :
  SPV_GLSLOp<mnemonic, opcode, !listconcat([NoSideEffect], traits)> {

  let arguments = (ins
    SPV_ScalarOrVectorOf<operandType>:$operand
  );

  let results = (outs
    SPV_ScalarOrVectorOf<resultType>:$result
  );

  let parser = [{ return parseUnaryOp(parser, result); }];

  let printer = [{ return printUnaryOp(getOperation(), p); }];

  let verifier = [{ return success(); }];
}

// Base class for GLSL Unary arithmetic ops where return type matches
// the operand type.
class SPV_GLSLUnaryArithmeticOp<string mnemonic, int opcode, Type type,
                                list<OpTrait> traits = []> :
  SPV_GLSLUnaryOp<mnemonic, opcode, type, type, traits>;

// Base class for GLSL binary ops.
class SPV_GLSLBinaryOp<string mnemonic, int opcode, Type resultType,
                        Type operandType, list<OpTrait> traits = []> :
  SPV_GLSLOp<mnemonic, opcode, !listconcat([NoSideEffect], traits)> {

  let arguments = (ins
    SPV_ScalarOrVectorOf<operandType>:$lhs,
    SPV_ScalarOrVectorOf<operandType>:$rhs
  );

  let results = (outs
    SPV_ScalarOrVectorOf<resultType>:$result
  );

  let parser = [{ return impl::parseOneResultSameOperandTypeOp(parser, result); }];

  let printer = [{ return impl::printOneResultOp(getOperation(), p); }];

  let verifier = [{ return success(); }];
}

// Base class for GLSL Binary arithmetic ops where operand types and
// return type matches.
class SPV_GLSLBinaryArithmeticOp<string mnemonic, int opcode, Type type,
                                 list<OpTrait> traits = []> :
  SPV_GLSLBinaryOp<mnemonic, opcode, type, type, traits>;

// -----

def SPV_GLSLFAbsOp : SPV_GLSLUnaryArithmeticOp<"FAbs", 4, SPV_Float> {
  let summary = "Absolute value of operand";

  let description = [{
    Result is x if x >= 0; otherwise result is -x.

    The operand x must be a scalar or vector whose component type is
    floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    float-scalar-vector-type ::= float-type |
                                 `vector<` integer-literal `x` float-type `>`
    abs-op ::= ssa-id `=` `spv.GLSL.FAbs` ssa-use `:`
               float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.FAbs %0 : f32
    %3 = spv.GLSL.FAbs %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLSAbsOp : SPV_GLSLUnaryArithmeticOp<"SAbs", 5, SPV_Integer> {
  let summary = "Absolute value of operand";

  let description = [{
    Result is x if x ??? 0; otherwise result is -x, where x is interpreted as a
    signed integer.

    Result Type and the type of x must both be integer scalar or integer vector
    types. Result Type and operand types must have the same number of components
    with the same component width. Results are computed per component.

    <!-- End of AutoGen section -->
    ```
    integer-scalar-vector-type ::= integer-type |
                                   `vector<` integer-literal `x` integer-type `>`
    abs-op ::= ssa-id `=` `spv.GLSL.SAbs` ssa-use `:`
               integer-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.SAbs %0 : i32
    %3 = spv.GLSL.SAbs %1 : vector<3xi16>
    ```
  }];
}

// -----

def SPV_GLSLCeilOp : SPV_GLSLUnaryArithmeticOp<"Ceil", 9, SPV_Float> {
  let summary = "Rounds up to the next whole number";

  let description = [{
    Result is the value equal to the nearest whole number that is greater than
    or equal to x.

    The operand x must be a scalar or vector whose component type is
    floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    float-scalar-vector-type ::= float-type |
                                 `vector<` integer-literal `x` float-type `>`
    ceil-op ::= ssa-id `=` `spv.GLSL.Ceil` ssa-use `:`
                float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Ceil %0 : f32
    %3 = spv.GLSL.Ceil %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLCosOp : SPV_GLSLUnaryArithmeticOp<"Cos", 14, SPV_Float16or32> {
  let summary = "Cosine of operand in radians";

  let description = [{
    The standard trigonometric cosine of x radians.

    The operand x must be a scalar or vector whose component type is 16-bit or
    32-bit floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    restricted-float-scalar-type ::=  `f16` | `f32`
    restricted-float-scalar-vector-type ::=
      restricted-float-scalar-type |
      `vector<` integer-literal `x` restricted-float-scalar-type `>`
    cos-op ::= ssa-id `=` `spv.GLSL.Cos` ssa-use `:`
               restricted-float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Cos %0 : f32
    %3 = spv.GLSL.Cos %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLSinOp : SPV_GLSLUnaryArithmeticOp<"Sin", 13, SPV_Float16or32> {
  let summary = "Sine of operand in radians";

  let description = [{
    The standard trigonometric sine of x radians.

    The operand x must be a scalar or vector whose component type is 16-bit or
    32-bit floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    restricted-float-scalar-type ::=  `f16` | `f32`
    restricted-float-scalar-vector-type ::=
      restricted-float-scalar-type |
      `vector<` integer-literal `x` restricted-float-scalar-type `>`
    sin-op ::= ssa-id `=` `spv.GLSL.Sin` ssa-use `:`
               restricted-float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Sin %0 : f32
    %3 = spv.GLSL.Sin %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLTanOp : SPV_GLSLUnaryArithmeticOp<"Tan", 15, SPV_Float16or32> {
  let summary = "Tangent of operand in radians";

  let description = [{
    The standard trigonometric tangent of x radians.

    The operand x must be a scalar or vector whose component type is 16-bit or 
    32-bit floating-point.

    Result Type and the type of x must be the same type. Results are computed 
    per component.

    <!-- End of AutoGen section -->
    ```
    restricted-float-scalar-type ::=  `f16` | `f32`
    restricted-float-scalar-vector-type ::=
      restricted-float-scalar-type |
      `vector<` integer-literal `x` restricted-float-scalar-type `>`
    tan-op ::= ssa-id `=` `spv.GLSL.Tan` ssa-use `:`
               restricted-float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Tan %0 : f32
    %3 = spv.GLSL.Tan %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLAsinOp : SPV_GLSLUnaryArithmeticOp<"Asin", 16, SPV_Float16or32> {
  let summary = "Arc Sine of operand in radians";

  let description = [{
    The standard trigonometric arc sine of x radians.

    Result is an angle, in radians, whose sine is x. The range of result values
    is [-?? / 2, ?? / 2]. Result is undefined if abs x > 1.

    The operand x must be a scalar or vector whose component type is 16-bit or
    32-bit floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.
    <!-- End of AutoGen section -->
    ```
    restricted-float-scalar-type ::=  `f16` | `f32`
    restricted-float-scalar-vector-type ::=
      restricted-float-scalar-type |
      `vector<` integer-literal `x` restricted-float-scalar-type `>`
    asin-op ::= ssa-id `=` `spv.GLSL.Asin` ssa-use `:`
                restricted-float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Asin %0 : f32
    %3 = spv.GLSL.Asin %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLAcosOp : SPV_GLSLUnaryArithmeticOp<"Acos", 17, SPV_Float16or32> {
  let summary = "Arc Cosine of operand in radians";

  let description = [{
    The standard trigonometric arc cosine of x radians.

    Result is an angle, in radians, whose cosine is x. The range of result
    values is [0, ??]. Result is undefined if abs x > 1.

    The operand x must be a scalar or vector whose component type is 16-bit or
    32-bit floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.
    <!-- End of AutoGen section -->
    ```
    restricted-float-scalar-type ::=  `f16` | `f32`
    restricted-float-scalar-vector-type ::=
      restricted-float-scalar-type |
      `vector<` integer-literal `x` restricted-float-scalar-type `>`
    acos-op ::= ssa-id `=` `spv.GLSL.Acos` ssa-use `:`
                restricted-float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Acos %0 : f32
    %3 = spv.GLSL.Acos %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLAtanOp : SPV_GLSLUnaryArithmeticOp<"Atan", 18, SPV_Float16or32> {
  let summary = "Arc Tangent of operand in radians";

  let description = [{
    The standard trigonometric arc tangent of x radians.

    Result is an angle, in radians, whose tangent is y_over_x. The range of
    result values is [-?? / 2, ?? / 2].

    The operand x must be a scalar or vector whose component type is 16-bit or
    32-bit floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.
    <!-- End of AutoGen section -->
    ```
    restricted-float-scalar-type ::=  `f16` | `f32`
    restricted-float-scalar-vector-type ::=
      restricted-float-scalar-type |
      `vector<` integer-literal `x` restricted-float-scalar-type `>`
    atan-op ::= ssa-id `=` `spv.GLSL.Atan` ssa-use `:`
                restricted-float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Atan %0 : f32
    %3 = spv.GLSL.Atan %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLExpOp : SPV_GLSLUnaryArithmeticOp<"Exp", 27, SPV_Float16or32> {
  let summary = "Exponentiation of Operand 1";

  let description = [{
    Result is the natural exponentiation of x; e^x.

    The operand x must be a scalar or vector whose component type is
    16-bit or 32-bit floating-point.

    Result Type and the type of x must be the same type. Results are
    computed per component.";

    <!-- End of AutoGen section -->
    ```
    restricted-float-scalar-type ::=  `f16` | `f32`
    restricted-float-scalar-vector-type ::=
      restricted-float-scalar-type |
      `vector<` integer-literal `x` restricted-float-scalar-type `>`
    exp-op ::= ssa-id `=` `spv.GLSL.Exp` ssa-use `:`
               restricted-float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Exp %0 : f32
    %3 = spv.GLSL.Exp %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLFloorOp : SPV_GLSLUnaryArithmeticOp<"Floor", 8, SPV_Float> {
  let summary = "Rounds down to the next whole number";

  let description = [{
    Result is the value equal to the nearest whole number that is less than or
    equal to x.

    The operand x must be a scalar or vector whose component type is
    floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    float-scalar-vector-type ::= float-type |
                                 `vector<` integer-literal `x` float-type `>`
    floor-op ::= ssa-id `=` `spv.GLSL.Floor` ssa-use `:`
                float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Floor %0 : f32
    %3 = spv.GLSL.Floor %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLRoundOp: SPV_GLSLUnaryArithmeticOp<"Round", 1, SPV_Float> {
  let summary = "Rounds to the whole number";

  let description = [{
    Result is the value equal to the nearest whole number.

    The operand x must be a scalar or vector whose component type is
    floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    float-scalar-vector-type ::= float-type |
                                 `vector<` integer-literal `x` float-type `>`
    floor-op ::= ssa-id `=` `spv.GLSL.Round` ssa-use `:`
                float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Round %0 : f32
    %3 = spv.GLSL.Round %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLInverseSqrtOp : SPV_GLSLUnaryArithmeticOp<"InverseSqrt", 32, SPV_Float> {
  let summary = "Reciprocal of sqrt(operand)";

  let description = [{
    Result is the reciprocal of sqrt x. Result is undefined if x <= 0.

    The operand x must be a scalar or vector whose component type is
    floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    float-scalar-vector-type ::= float-type |
                                 `vector<` integer-literal `x` float-type `>`
    rsqrt-op ::= ssa-id `=` `spv.GLSL.InverseSqrt` ssa-use `:`
                 float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.InverseSqrt %0 : f32
    %3 = spv.GLSL.InverseSqrt %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLLogOp : SPV_GLSLUnaryArithmeticOp<"Log", 28, SPV_Float16or32> {
  let summary = "Natural logarithm of the operand";

  let description = [{
    Result is the natural logarithm of x, i.e., the value y which satisfies the
    equation x = ey. Result is undefined if x <= 0.

    The operand x must be a scalar or vector whose component type is 16-bit or
    32-bit floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    restricted-float-scalar-type ::=  `f16` | `f32`
    restricted-float-scalar-vector-type ::=
      restricted-float-scalar-type |
      `vector<` integer-literal `x` restricted-float-scalar-type `>`
    log-op ::= ssa-id `=` `spv.GLSL.Log` ssa-use `:`
               restricted-float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Log %0 : f32
    %3 = spv.GLSL.Log %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLFMaxOp : SPV_GLSLBinaryArithmeticOp<"FMax", 40, SPV_Float> {
  let summary = "Return maximum of two floating-point operands";

  let description = [{
    Result is y if x < y; otherwise result is x. Which operand is the
    result is undefined if one of the operands is a NaN.

    The operands must all be a scalar or vector whose component type
    is floating-point.

    Result Type and the type of all operands must be the same
    type. Results are computed per component.

    <!-- End of AutoGen section -->
    ```
    float-scalar-vector-type ::= float-type |
                                 `vector<` integer-literal `x` float-type `>`
    fmax-op ::= ssa-id `=` `spv.GLSL.FMax` ssa-use `:`
                float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.FMax %0, %1 : f32
    %3 = spv.GLSL.FMax %0, %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLSMaxOp : SPV_GLSLBinaryArithmeticOp<"SMax", 42, SPV_Integer> {
  let summary = "Return maximum of two signed integer operands";

  let description = [{
    Result is y if x < y; otherwise result is x, where x and y are interpreted
    as signed integers.

    Result Type and the type of x and y must both be integer scalar or integer
    vector types. Result Type and operand types must have the same number of
    components with the same component width. Results are computed per
    component.

    <!-- End of AutoGen section -->
    ```
    integer-scalar-vector-type ::= integer-type |
                                   `vector<` integer-literal `x` integer-type `>`
    smax-op ::= ssa-id `=` `spv.GLSL.SMax` ssa-use `:`
                integer-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.SMax %0, %1 : i32
    %3 = spv.GLSL.SMax %0, %1 : vector<3xi16>
    ```
  }];
}

// -----

def SPV_GLSLFMinOp : SPV_GLSLBinaryArithmeticOp<"FMin", 37, SPV_Float> {
  let summary = "Return minimum of two floating-point operands";

  let description = [{
    Result is y if y < x; otherwise result is x. Which operand is the result is
    undefined if one of the operands is a NaN.

    The operands must all be a scalar or vector whose component type is
    floating-point.

    Result Type and the type of all operands must be the same type. Results are
    computed per component.

    <!-- End of AutoGen section -->
    ```
    float-scalar-vector-type ::= float-type |
                                 `vector<` integer-literal `x` float-type `>`
    fmin-op ::= ssa-id `=` `spv.GLSL.FMin` ssa-use `:`
                float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.FMin %0, %1 : f32
    %3 = spv.GLSL.FMin %0, %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLSMinOp : SPV_GLSLBinaryArithmeticOp<"SMin", 39, SPV_Integer> {
  let summary = "Return minimum of two signed integer operands";

  let description = [{
    Result is y if y < x; otherwise result is x, where x and y are interpreted
    as signed integers.

    Result Type and the type of x and y must both be integer scalar or integer
    vector types. Result Type and operand types must have the same number of
    components with the same component width. Results are computed per
    component.

    <!-- End of AutoGen section -->
    ```
    integer-scalar-vector-type ::= integer-type |
                                   `vector<` integer-literal `x` integer-type `>`
    smin-op ::= ssa-id `=` `spv.GLSL.SMin` ssa-use `:`
                integer-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.SMin %0, %1 : i32
    %3 = spv.GLSL.SMin %0, %1 : vector<3xi16>
    ```
  }];
}

// -----

def SPV_GLSLPowOp : SPV_GLSLBinaryArithmeticOp<"Pow", 26, SPV_Float16or32> {
  let summary = "Return x raised to the y power of two operands";

  let description = [{
    Result is x raised to the y power; x^y.

    Result is undefined if x = 0 and y ??? 0.

    The operand x and y must be a scalar or vector whose component type is
    16-bit or 32-bit floating-point.

    Result Type and the type of all operands must be the same type. Results are
    computed per component.

    <!-- End of AutoGen section -->
    ```
    restricted-float-scalar-type ::=  `f16` | `f32`
    restricted-float-scalar-vector-type ::=
      restricted-float-scalar-type |
      `vector<` integer-literal `x` restricted-float-scalar-type `>`
    pow-op ::= ssa-id `=` `spv.GLSL.Pow` ssa-use `:`
               restricted-float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Pow %0, %1 : f32
    %3 = spv.GLSL.Pow %0, %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLFSignOp : SPV_GLSLUnaryArithmeticOp<"FSign", 6, SPV_Float> {
  let summary = "Returns the sign of the operand";

  let description = [{
    Result is 1.0 if x > 0, 0.0 if x = 0, or -1.0 if x < 0.

    The operand x must be a scalar or vector whose component type is
    floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    float-scalar-vector-type ::= float-type |
                                 `vector<` integer-literal `x` float-type `>`
    sign-op ::= ssa-id `=` `spv.GLSL.FSign` ssa-use `:`
                float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.FSign %0 : f32
    %3 = spv.GLSL.FSign %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLSSignOp : SPV_GLSLUnaryArithmeticOp<"SSign", 7, SPV_Integer> {
  let summary = "Returns the sign of the operand";

  let description = [{
    Result is 1 if x > 0, 0 if x = 0, or -1 if x < 0, where x is interpreted as
    a signed integer.

    Result Type and the type of x must both be integer scalar or integer vector
    types. Result Type and operand types must have the same number of components
    with the same component width. Results are computed per component.

    <!-- End of AutoGen section -->
    ```
    integer-scalar-vector-type ::= integer-type |
                                   `vector<` integer-literal `x` integer-type `>`
    sign-op ::= ssa-id `=` `spv.GLSL.SSign` ssa-use `:`
                integer-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.SSign %0 : i32
    %3 = spv.GLSL.SSign %1 : vector<3xi16>
    ```
  }];
}

// -----

def SPV_GLSLSqrtOp : SPV_GLSLUnaryArithmeticOp<"Sqrt", 31, SPV_Float> {
  let summary = "Returns the square root of the operand";

  let description = [{
    Result is the square root of x. Result is undefined if x < 0.

    The operand x must be a scalar or vector whose component type is
    floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    float-scalar-vector-type ::= float-type |
                                 `vector<` integer-literal `x` float-type `>`
    sqrt-op ::= ssa-id `=` `spv.GLSL.Sqrt` ssa-use `:`
                float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Sqrt %0 : f32
    %3 = spv.GLSL.Sqrt %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLSinhOp : SPV_GLSLUnaryArithmeticOp<"Sinh", 19, SPV_Float16or32> {
  let summary = "Hyperbolic sine of operand in radians";

  let description = [{
    Hyperbolic sine of x radians.

    The operand x must be a scalar or vector whose component type is 16-bit or
    32-bit floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    restricted-float-scalar-type ::=  `f16` | `f32`
    restricted-float-scalar-vector-type ::=
      restricted-float-scalar-type |
      `vector<` integer-literal `x` restricted-float-scalar-type `>`
    sinh-op ::= ssa-id `=` `spv.GLSL.Sinh` ssa-use `:`
                restricted-float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Sinh %0 : f32
    %3 = spv.GLSL.Sinh %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLCoshOp : SPV_GLSLUnaryArithmeticOp<"Cosh", 20, SPV_Float16or32> {
  let summary = "Hyperbolic cosine of operand in radians";

  let description = [{
    Hyperbolic cosine of x radians.

    The operand x must be a scalar or vector whose component type is 16-bit or
    32-bit floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    restricted-float-scalar-type ::=  `f16` | `f32`
    restricted-float-scalar-vector-type ::=
      restricted-float-scalar-type |
      `vector<` integer-literal `x` restricted-float-scalar-type `>`
    cosh-op ::= ssa-id `=` `spv.GLSL.Cosh` ssa-use `:`
                restricted-float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Cosh %0 : f32
    %3 = spv.GLSL.Cosh %1 : vector<3xf16>
    ```
  }];
}

// -----

def SPV_GLSLTanhOp : SPV_GLSLUnaryArithmeticOp<"Tanh", 21, SPV_Float16or32> {
  let summary = "Hyperbolic tangent of operand in radians";

  let description = [{
    Hyperbolic tangent of x radians.

    The operand x must be a scalar or vector whose component type is 16-bit or
    32-bit floating-point.

    Result Type and the type of x must be the same type. Results are computed
    per component.

    <!-- End of AutoGen section -->
    ```
    restricted-float-scalar-type ::=  `f16` | `f32`
    restricted-float-scalar-vector-type ::=
      restricted-float-scalar-type |
      `vector<` integer-literal `x` restricted-float-scalar-type `>`
    tanh-op ::= ssa-id `=` `spv.GLSL.Tanh` ssa-use `:`
                restricted-float-scalar-vector-type
    ```
    #### Example:

    ```mlir
    %2 = spv.GLSL.Tanh %0 : f32
    %3 = spv.GLSL.Tanh %1 : vector<3xf16>
    ```
  }];
}

#endif // SPIRV_GLSL_OPS
