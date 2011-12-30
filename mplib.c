
#include <alloca.h>
#include <string.h>

#include "lua.h"
#include "lauxlib.h"

#include <mpfr.h>

static mpfr_prec_t _mp_prec = 53;
static mpfr_rnd_t _mp_rnd = GMP_RNDN;

static gmp_randstate_t mp_rndstate;


static int mp_new(lua_State *L)
{
	mpfr_ptr x = lua_newuserdata(L, sizeof(mpfr_t));

	mpfr_init2(x, _mp_prec);

	if (lua_isnumber(L, 1)) {
		mpfr_set_d(x, lua_tonumber(L, 1), _mp_rnd);
	}
	else {
		mpfr_set_str(x, lua_tostring(L, 1), 10, _mp_rnd);
	}

	luaL_getmetatable(L, "mp.obj");
	lua_setmetatable(L, -2);

	return 1;
}

static int mp_gc(lua_State *L)
{
	mpfr_ptr x = luaL_checkudata(L, 1, "mp.obj");
	mpfr_clear(x);

	return 0;
}

static int mp_tonumber(lua_State *L)
{
	mpfr_ptr x = luaL_checkudata(L, 1, "mp.obj");
	lua_pushnumber(L, mpfr_get_d(x, _mp_rnd));

	return 1;
}

static int mp_tostring(lua_State *L)
{
	char buf[256];

	mpfr_ptr x = luaL_checkudata(L, 1, "mp.obj");

	int n = mpfr_snprintf (buf, sizeof(buf), "%.21Re", x);
	lua_pushlstring(L, buf, n);

	return 1;
}

static int mp_format(lua_State *L)
{
	char buf[256];

	const char *str = lua_tostring(L, 1);
	mpfr_ptr x = luaL_checkudata(L, 2, "mp.obj");

	int n = mpfr_snprintf (buf, sizeof(buf), str, x);
	lua_pushlstring(L, buf, n);

	return 1;
}

static int mp_set_prec(lua_State *L)
{
	lua_pushinteger(L, _mp_prec);
	_mp_prec = lua_tointeger(L, 1);
	if (_mp_prec < MPFR_PREC_MIN) {
		_mp_prec = MPFR_PREC_MIN;
	}
	else if (_mp_prec > MPFR_PREC_MAX) {
		_mp_prec = MPFR_PREC_MAX;
	}

	return 1;
}

static int mp_set_rnd(lua_State *L)
{
	const char *str = lua_tostring(L, 1);

	switch (_mp_rnd) {
	case GMP_RNDN:
		lua_pushstring(L, "RNDN");
		break;
	case GMP_RNDZ:
		lua_pushstring(L, "RNDZ");
		break;
	case GMP_RNDU:
		lua_pushstring(L, "RNDU");
		break;
	case GMP_RNDD:
		lua_pushstring(L, "RNDD");
		break;
	default:
		break;
	}

	if (!str) {
		_mp_rnd = GMP_RNDN;
	}
	else if (!strcmp("RNDN", str)) {
		_mp_rnd = GMP_RNDN;
	}
	else if (!strcmp("RNDZ", str)) {
		_mp_rnd = GMP_RNDZ;
	}
	else if (!strcmp("RNDU", str)) {
		_mp_rnd = GMP_RNDU;
	}
	else if (!strcmp("RNDD", str)) {
		_mp_rnd = GMP_RNDD;
	}

	return 1;
}

static int mp_clear_flags(lua_State *L)
{
	mpfr_clear_flags();
	return 0;
}

#define MPFR_GET_FLAG(FUNC) \
	static int mp_get_##FUNC(lua_State *L) { \
		lua_pushboolean(L, mpfr_##FUNC##_p());	\
		return 1; \
	}

#define MPFR_SET_FLAG(FUNC) \
	static int mp_set_##FUNC(lua_State *L) { \
		if (lua_toboolean(L, 1)) { \
			mpfr_set_##FUNC();	\
		} \
		return 0; \
	}

MPFR_GET_FLAG(underflow);
MPFR_GET_FLAG(overflow);
MPFR_GET_FLAG(nanflag);
MPFR_GET_FLAG(inexflag);
MPFR_GET_FLAG(erangeflag);

MPFR_SET_FLAG(underflow);
MPFR_SET_FLAG(overflow);
MPFR_SET_FLAG(nanflag);
MPFR_SET_FLAG(inexflag);
MPFR_SET_FLAG(erangeflag);

#define MPFR_CMP(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mpfr_ptr a = luaL_checkudata(L, 1, "mp.obj"); \
		mpfr_ptr b = luaL_checkudata(L, 2, "mp.obj"); \
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
		mpfr_ptr a = luaL_checkudata(L, 1, "mp.obj"); \
		mpfr_ptr x = lua_newuserdata(L, sizeof(mpfr_t)); \
		mpfr_init2(x, _mp_prec); \
		mpfr_##FUNC(x, a, _mp_rnd); \
		luaL_getmetatable(L, "mp.obj"); \
		lua_setmetatable(L, -2); \
		return 1; \
	}

#define MPFR_OP1X(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mpfr_ptr a = luaL_checkudata(L, 1, "mp.obj"); \
		mpfr_ptr x = lua_newuserdata(L, sizeof(mpfr_t)); \
		mpfr_init2(x, _mp_prec); \
		mpfr_##FUNC(x, a); \
		luaL_getmetatable(L, "mp.obj"); \
		lua_setmetatable(L, -2); \
		return 1; \
	}

#define MPFR_OP2(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mpfr_ptr a = luaL_checkudata(L, 1, "mp.obj"); \
		mpfr_ptr b = luaL_checkudata(L, 2, "mp.obj"); \
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


static int mp_fac(lua_State *L) {
	mpfr_ptr a = luaL_checkudata(L, 1, "mp.obj");
	mpfr_ptr x = lua_newuserdata(L, sizeof(mpfr_t));
	mpfr_init2(x, _mp_prec);
	mpfr_fac_ui(x, mpfr_get_ui(a, MPFR_RNDZ), _mp_rnd);
	luaL_getmetatable(L, "mp.obj");
	lua_setmetatable(L, -2);
	return 1;
}

static int mp_root(lua_State *L) {
	mpfr_ptr a = luaL_checkudata(L, 1, "mp.obj");
	mpfr_ptr b = luaL_checkudata(L, 2, "mp.obj");
	mpfr_ptr x = lua_newuserdata(L, sizeof(mpfr_t));
	mpfr_init2(x, _mp_prec);
	mpfr_root(x, b, mpfr_get_ui(a, MPFR_RNDZ), _mp_rnd);
	luaL_getmetatable(L, "mp.obj");
	lua_setmetatable(L, -2);
	return 1;
}

static int mp_urandom(lua_State *L) {
	mpfr_ptr x = lua_newuserdata(L, sizeof(mpfr_t));
	mpfr_init2(x, _mp_prec);
	mpfr_urandom(x, mp_rndstate, _mp_rnd);
	luaL_getmetatable(L, "mp.obj");
	lua_setmetatable(L, -2);
	return 1;
}


#define MPREG(FUNC) { #FUNC, mp_##FUNC }

static const struct luaL_Reg mp[] = {
	MPREG(new),
	MPREG(format),
	MPREG(set_prec),
	MPREG(set_rnd),
	MPREG(clear_flags),
	MPREG(get_underflow),
	MPREG(get_overflow),
	MPREG(get_nanflag),
	MPREG(get_inexflag),
	MPREG(get_erangeflag),
	MPREG(set_underflow),
	MPREG(set_overflow),
	MPREG(set_nanflag),
	MPREG(set_inexflag),
	MPREG(set_erangeflag),
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
	MPREG(fac),
	MPREG(root),
	MPREG(urandom),
	{ NULL, NULL }
};

static const struct luaL_Reg mp_m[] = 
{	{ "__eq", mp_equal },
	{ "__lt", mp_less },
	{ "__le", mp_lessequal },
	{ "__gc", mp_gc },
	{ "tonumber", mp_tonumber },
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
	gmp_randinit_default(mp_rndstate);

	luaL_newmetatable(L, "mp.obj");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_register(L, NULL, mp_m);

	luaL_register(L, "mp", mp);
	return 1;
}
