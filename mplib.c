
#include <alloca.h>
#include <assert.h>
#include <string.h>

#include "lua.h"
#include "lauxlib.h"

#include <mpfr.h>

static mpfr_prec_t _mp_prec = 53;
static mpfr_rnd_t _mp_rnd = GMP_RNDN;

static gmp_randstate_t mp_rndstate;

#define UNIT_LEN 20

typedef struct {
	mpfr_t mp;
	char unit[UNIT_LEN];
} mplib_t;

typedef mplib_t* mplib_ptr;

void mplib_init2(mplib_ptr x, mpfr_prec_t prec)
{
	mpfr_init2(x->mp, prec);
	*x->unit = '\0';
}

static int mp_new(lua_State *L)
{
	size_t unit_len;
	const char *unit = lua_tolstring(L, 2, &unit_len);

	mplib_ptr x = lua_newuserdata(L, sizeof(mplib_t));
	mplib_init2(x, _mp_prec);

	if (lua_type(L, 1) == LUA_TUSERDATA) {
		mplib_ptr a = luaL_checkudata(L, 1, "mp.obj");
		mpfr_set(x->mp, a->mp, _mp_rnd);
	}
	else if (lua_type(L, 1) == LUA_TNUMBER) {
		mpfr_set_d(x->mp, lua_tonumber(L, 1), _mp_rnd);
	}
	else {
		mpfr_set_str(x->mp, lua_tostring(L, 1), 10, _mp_rnd);
	}

	assert(unit_len < sizeof(x->unit) - 1);
	memcpy(x->unit, unit, unit_len);
	x->unit[unit_len] = '\0';

	luaL_getmetatable(L, "mp.obj");
	lua_setmetatable(L, -2);

	return 1;
}

static int mp_gc(lua_State *L)
{
	mplib_ptr x = luaL_checkudata(L, 1, "mp.obj");
	mpfr_clear(x->mp);

	return 0;
}

static int mp_unit(lua_State *L)
{
	mplib_ptr x = luaL_checkudata(L, 1, "mp.obj");
	if (*x->unit) {
		lua_pushstring(L, x->unit);
	}
	else {
		lua_pushnil(L);
	}

	return 1;
}

static int mp_tonumber(lua_State *L)
{
	mplib_ptr x = luaL_checkudata(L, 1, "mp.obj");
	lua_pushnumber(L, mpfr_get_d(x->mp, _mp_rnd));

	return 1;
}

static int mp_tostring(lua_State *L)
{
	char buf[256];

	mplib_ptr x = luaL_checkudata(L, 1, "mp.obj");

	int n = mpfr_snprintf(buf, sizeof(buf), "%Re%s", x->mp, x->unit);
	lua_pushlstring(L, buf, n);

	return 1;
}

static int mp_format(lua_State *L)
{
	char buf[256];

	const char *str = lua_tostring(L, 1);
	mplib_ptr x = luaL_checkudata(L, 2, "mp.obj");

	int n = mpfr_snprintf(buf, sizeof(buf), str, x->mp, x->unit);
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


void mplib_convert(lua_State *L, const char *func,
		   mplib_ptr *aptr, mplib_ptr *bptr, mplib_ptr x)
{
	mplib_ptr a = *aptr, b = *bptr;
	char key[UNIT_LEN * 2];

	lua_getglobal(L, "mp");
	int mplib_index = lua_gettop(L);
	lua_getfield(L, -1, "cast");

	/* lookup function */
	lua_getfield(L, -1, func);

	/* lookup units */
	strcpy(key, a->unit);
	if (b && *b->unit) {
		int n = strlen(key);
		key[n++] = ',';
		strcpy(key + n, b->unit);
	}
	lua_getfield(L, -1, key);

	if (lua_isnil(L, -1)) {
		/* automatic cast for single unit */
		if (b && *a->unit && !*b->unit) {
			strncpy(x->unit, a->unit, sizeof(x->unit));
			lua_pop(L, 4);
			return;
		}

		if (b && !*a->unit && *b->unit) {
			strncpy(x->unit, b->unit, sizeof(x->unit));
			lua_pop(L, 4);
			return;
		}

		/* equal units */
		if (b && !strncmp(a->unit, b->unit, sizeof(a->unit))) {
			strncpy(x->unit, a->unit, sizeof(x->unit));
			lua_pop(L, 4);
			return;
		}

		/* no entry in casting table
		 * try to cast all values to the first unit
		 */
		lua_pop(L, 1);
		lua_createtable(L, 3, 0);
		lua_pushstring(L, a->unit);
		lua_rawseti(L, -2, 1);
		lua_pushstring(L, a->unit);
		lua_rawseti(L, -2, 2);
		lua_pushstring(L, a->unit);
		lua_rawseti(L, -2, 3);
	}

	/* x unit */
	lua_rawgeti(L, -1, 1);
	strncpy(x->unit, lua_tostring(L, -1), sizeof(x->unit));
	lua_pop(L, 1);

	/* a unit */
	lua_rawgeti(L, -1, 2);
	if (!a->unit || strcmp(a->unit, luaL_optstring(L, -1, ""))) {
		lua_getfield(L, mplib_index, "convert");
		lua_pushvalue(L, 1); /* 'a' mp.obj */
		lua_pushvalue(L, -3); /* unit */
		lua_call(L, 2, 1);

		*aptr = luaL_checkudata(L, -1, "mp.obj");
		lua_pop(L, 1);
	}
	lua_pop(L, 1);

	/* b unit */
	lua_rawgeti(L, -1, 3);
	if (b && (!b->unit || strcmp(b->unit, luaL_optstring(L, -1, "")))) {
		lua_getfield(L, mplib_index, "convert");
		lua_pushvalue(L, 2); /* 'b' mp.obj */
		lua_pushvalue(L, -3); /* unit */
		lua_call(L, 2, 1);

		*bptr = luaL_checkudata(L, -1, "mp.obj");
		lua_pop(L, 1);
	}
	lua_pop(L, 5);
}


#define MPFR_CMP(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mpfr_ptr a = luaL_checkudata(L, 1, "mp.obj"); \
		mpfr_ptr b = luaL_checkudata(L, 2, "mp.obj"); \
		lua_pushboolean(L, mpfr_##FUNC##_p(a, b)); \
		return 1; \
	}


#define MPFR_CONST(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mplib_ptr x = lua_newuserdata(L, sizeof(mplib_t)); \
		mplib_init2(x, _mp_prec); \
		mpfr_const_##FUNC(x->mp, _mp_rnd); \
		luaL_getmetatable(L, "mp.obj"); \
		lua_setmetatable(L, -2); \
		return 1; \
	}

#define MPFR_OP1(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mplib_ptr a = luaL_checkudata(L, 1, "mp.obj"); \
		mplib_ptr x = lua_newuserdata(L, sizeof(mplib_t)); \
		mplib_init2(x, _mp_prec); \
		mpfr_##FUNC(x->mp, a->mp, _mp_rnd); \
		strcpy(x->unit, a->unit); \
		luaL_getmetatable(L, "mp.obj"); \
		lua_setmetatable(L, -2); \
		return 1; \
	}

#define MPFR_OP1_CAST(FUNC, UNIT_IN, UNIT_OUT) \
	static int mp_##FUNC(lua_State *L) { \
		mplib_ptr a = luaL_checkudata(L, 1, "mp.obj"); \
		if (UNIT_IN && *a->unit) { \
			lua_getglobal(L, "mp"); \
			lua_getfield(L, -1, "convert"); \
			lua_pushvalue(L, 1); /* 'a' mp.obj */ \
			lua_pushstring(L, UNIT_IN); /* unit */ \
			lua_call(L, 2, 1); \
			a = luaL_checkudata(L, -1, "mp.obj"); \
			lua_pop(L, 2); \
		} \
		mplib_ptr x = lua_newuserdata(L, sizeof(mplib_t)); \
		mplib_init2(x, _mp_prec); \
		mpfr_##FUNC(x->mp, a->mp, _mp_rnd); \
		strcpy(x->unit, UNIT_OUT); \
		luaL_getmetatable(L, "mp.obj"); \
		lua_setmetatable(L, -2); \
		return 1; \
	}

#define MPFR_OP1X(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mplib_ptr a = luaL_checkudata(L, 1, "mp.obj"); \
		mplib_ptr x = lua_newuserdata(L, sizeof(mplib_t)); \
		mplib_init2(x, _mp_prec); \
		mpfr_##FUNC(x->mp, a->mp); \
		strcpy(x->unit, a->unit); \
		luaL_getmetatable(L, "mp.obj"); \
		lua_setmetatable(L, -2); \
		return 1; \
	}

#define MPFR_OP2(FUNC) \
	static int mp_##FUNC(lua_State *L) { \
		mplib_ptr a = luaL_checkudata(L, 1, "mp.obj"); \
		mplib_ptr b = luaL_checkudata(L, 2, "mp.obj"); \
		mplib_ptr x = lua_newuserdata(L, sizeof(mplib_t)); \
		mplib_init2(x, _mp_prec); \
		if (*a->unit || *b->unit) \
			mplib_convert(L, #FUNC, &a, &b, x); \
		mpfr_##FUNC(x->mp, a->mp, b->mp, _mp_rnd); \
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
MPFR_OP1_CAST(cos, "rad", "");
MPFR_OP1_CAST(sin, "rad", "");
MPFR_OP1_CAST(tan, "rad", "");
MPFR_OP1_CAST(sec, "rad", "");
MPFR_OP1_CAST(csc, "rad", "");
MPFR_OP1_CAST(cot, "rad", "");
MPFR_OP1_CAST(acos, "", "rad");
MPFR_OP1_CAST(asin, "", "rad");
MPFR_OP1_CAST(atan, "", "rad");
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
	mplib_ptr a = luaL_checkudata(L, 1, "mp.obj");
	mplib_ptr x = lua_newuserdata(L, sizeof(mplib_t));
	mplib_init2(x, _mp_prec);
	mpfr_fac_ui(x->mp, mpfr_get_ui(a->mp, MPFR_RNDZ), _mp_rnd);
	luaL_getmetatable(L, "mp.obj");
	lua_setmetatable(L, -2);
	return 1;
}

static int mp_root(lua_State *L) {
	mplib_ptr a = luaL_checkudata(L, 1, "mp.obj");
	mplib_ptr b = luaL_checkudata(L, 2, "mp.obj");
	mplib_ptr x = lua_newuserdata(L, sizeof(mplib_t));
	mplib_init2(x, _mp_prec);
	mpfr_root(x->mp, b->mp, mpfr_get_ui(a->mp, MPFR_RNDZ), _mp_rnd);
	luaL_getmetatable(L, "mp.obj");
	lua_setmetatable(L, -2);
	return 1;
}

static int mp_urandom(lua_State *L) {
	mplib_ptr x = lua_newuserdata(L, sizeof(mplib_t));
	mplib_init2(x, _mp_prec);
	mpfr_urandom(x->mp, mp_rndstate, _mp_rnd);
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
	{ "unit", mp_unit },
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
