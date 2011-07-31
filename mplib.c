
#include <alloca.h>
#include <string.h>

#include "lua.h"
#include "lauxlib.h"

#include <mpfr.h>

static mpfr_prec_t _mp_prec = 70;
static mpfr_rnd_t _mp_rnd = GMP_RNDN;

static int mp_new(lua_State *L)
{
	mpfr_ptr x = lua_newuserdata(L, sizeof(mpfr_t));

	mpfr_init2(x, _mp_prec);
	mpfr_set_str(x, lua_tostring(L, 1), 10, _mp_rnd);

	luaL_getmetatable(L, "mp.obj");
	lua_setmetatable(L, -2);

	return 1;
}

static int mp_gc(lua_State *L)
{
	mpfr_ptr x = lua_touserdata(L, 1);
	mpfr_clear(x);

	return 0;
}

static int mp_tostring(lua_State *L)
{
	char buf[256];

	mpfr_ptr x = lua_touserdata(L, 1);

	int n = mpfr_snprintf (buf, sizeof(buf), "%.21Re\n", x);
	lua_pushlstring(L, buf, n);

	return 1;
}

#define MPFR_CMP(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mpfr_ptr a = lua_touserdata(L, 1); \
		mpfr_ptr b = lua_touserdata(L, 2); \
		lua_pushboolean(L, mpfr_##FUNC##_p(a, b)); \
		return 1; \
	}


#define MPFR_CONST(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mpfr_ptr x = lua_newuserdata(L, sizeof(mpfr_t)); \
		mpfr_init2(x, _mp_prec); \
		mpfr_const_##FUNC(x, _mp_rnd); \
		luaL_getmetatable(L, "mp.obj"); \
		lua_setmetatable(L, -2); \
		return 1; \
	}

#define MPFR_OP1(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mpfr_ptr a = lua_touserdata(L, 1); \
		mpfr_ptr x = lua_newuserdata(L, sizeof(mpfr_t)); \
		mpfr_init2(x, _mp_prec); \
		mpfr_##FUNC(x, a, _mp_rnd); \
		luaL_getmetatable(L, "mp.obj"); \
		lua_setmetatable(L, -2); \
		return 1; \
	}

#define MPFR_OP1X(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mpfr_ptr a = lua_touserdata(L, 1); \
		mpfr_ptr x = lua_newuserdata(L, sizeof(mpfr_t)); \
		mpfr_init2(x, _mp_prec); \
		mpfr_##FUNC(x, a); \
		luaL_getmetatable(L, "mp.obj"); \
		lua_setmetatable(L, -2); \
		return 1; \
	}

#define MPFR_OP2(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mpfr_ptr a = lua_touserdata(L, 1); \
		mpfr_ptr b = lua_touserdata(L, 2); \
		mpfr_ptr x = lua_newuserdata(L, sizeof(mpfr_t)); \
		mpfr_init2(x, _mp_prec); \
		mpfr_##FUNC(x, a, b, _mp_rnd);	\
		luaL_getmetatable(L, "mp.obj"); \
		lua_setmetatable(L, -2); \
		return 1; \
	}


/* Basic Arithmetic Functions */
MPFR_OP2(add);
MPFR_OP2(sub);
MPFR_OP2(mul);
MPFR_OP1(sqr);
MPFR_OP2(div);
MPFR_OP1(sqrt);
MPFR_OP1(rec_sqrt);
MPFR_OP1(cbrt);
MPFR_OP2(pow);
MPFR_OP1(neg);
MPFR_OP1(abs);

/* Comparision Functions */
MPFR_CMP(greater);
MPFR_CMP(greaterequal);
MPFR_CMP(less);
MPFR_CMP(lessequal);
MPFR_CMP(equal);

/* Special Functions */
MPFR_OP1(log);
MPFR_OP1(log2);
MPFR_OP1(log10);
MPFR_OP1(exp);
MPFR_OP1(exp2);
MPFR_OP1(exp10);
MPFR_OP1(cos);
MPFR_OP1(sin);
MPFR_OP1(tan);
MPFR_OP1(sec);
MPFR_OP1(csc);
MPFR_OP1(cot);
MPFR_OP1(acos);
MPFR_OP1(asin);
MPFR_OP1(atan);
MPFR_OP2(atan2);
MPFR_OP1(cosh);
MPFR_OP1(sinh);
MPFR_OP1(tanh);
MPFR_OP1(sech);
MPFR_OP1(csch);
MPFR_OP1(coth);
MPFR_OP1(acosh);
MPFR_OP1(asinh);
MPFR_OP1(atanh);
MPFR_OP1(log1p);
MPFR_OP1(expm1);
MPFR_OP1(eint);
MPFR_OP1(li2);
MPFR_OP1(gamma);
MPFR_OP1(lngamma);
//MPFR_OP1(lgamma);
//MPFR_OP1(digamma);
MPFR_OP1(zeta);
MPFR_OP1(erf);
//MPFR_CONST(log2);
MPFR_CONST(pi);
MPFR_CONST(euler);
MPFR_CONST(catalan);

/* Integer and Remainder Related Functions */
MPFR_OP1X(ceil);
MPFR_OP1X(floor);
MPFR_OP1X(round);
MPFR_OP1X(trunc);
MPFR_OP1(rint_ceil);
MPFR_OP1(rint_floor);
MPFR_OP1(rint_round);
MPFR_OP1(rint_trunc);
//MPFR_OP1(rint_frac);
MPFR_OP2(fmod);
MPFR_OP2(remainder);


#define MPREG(FUNC) { #FUNC, mp_##FUNC }

static const struct luaL_Reg mp[] = {
	{ "new", mp_new },
	MPREG(add),
	MPREG(sub),
	MPREG(mul),
	MPREG(sqr),
	MPREG(div),
	MPREG(sqrt),
	MPREG(rec_sqrt),
	MPREG(cbrt),
	MPREG(pow),
	MPREG(neg),
	MPREG(abs),
	MPREG(greater),
	MPREG(greaterequal),
	MPREG(less),
	MPREG(lessequal),
	MPREG(equal),
	MPREG(log),
	MPREG(log2),
	MPREG(log10),
	MPREG(exp),
	MPREG(exp2),
	MPREG(exp10),
	MPREG(cos),
	MPREG(sin),
	MPREG(tan),
	MPREG(sec),
	MPREG(csc),
	MPREG(cot),
	MPREG(acos),
	MPREG(asin),
	MPREG(atan),
	MPREG(atan2),
	MPREG(cosh),
	MPREG(sinh),
	MPREG(tanh),
	MPREG(sech),
	MPREG(csch),
	MPREG(coth),
	MPREG(acosh),
	MPREG(asinh),
	MPREG(atanh),
	MPREG(log1p),
	MPREG(expm1),
	MPREG(eint),
	MPREG(li2),
	MPREG(gamma),
	MPREG(lngamma),
	//MPREG(lgamma),
	//MPREG(digamma),
	MPREG(zeta),
	MPREG(erf),
	//MPREG(log2),
	MPREG(pi),
	MPREG(euler),
	MPREG(catalan),
	MPREG(ceil),
	MPREG(floor),
	MPREG(round),
	MPREG(trunc),
	MPREG(rint_ceil),
	MPREG(rint_floor),
	MPREG(rint_round),
	MPREG(rint_trunc),
	//MPREG(rint_frac),
	MPREG(fmod),
	MPREG(remainder),
	{ NULL, NULL }
};

static const struct luaL_Reg mp_m[] = 
{	{ "__eq", mp_equal },
	{ "__lt", mp_less },
	{ "__le", mp_lessequal },
	{ "__gc", mp_gc },
	{ "__tostring", mp_tostring },
	{ "__add", mp_add },
	{ "__sub", mp_sub },
	{ "__mul", mp_mul },
	{ "__div", mp_div },
	{ "__pow", mp_pow },
	{ NULL, NULL }
};

int luaopen_mplib(lua_State *L)
{
	luaL_newmetatable(L, "mp.obj");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_register(L, NULL, mp_m);

	luaL_register(L, "mp", mp);
	return 1;
}
