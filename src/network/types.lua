local types = {
	null = 0,
	i8   = 1,
	i16  = 2,
	i32  = 3,
	i64  = 4,
	f32  = 11,
	f64  = 12
}
types.fmt = {
	[types.null] = "",
	[types.i8]   = "i1",
	[types.i16]  = "i2",
	[types.i32]  = "i4",
	[types.i64]  = "i8",
	[types.f32]  = "f",
	[types.f64]  = "d"
}

return types
