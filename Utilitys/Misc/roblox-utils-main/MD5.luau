local md5 = {}

local BYTE_MASK = 255  -- 0xFF
local WORD_MASK = 0xFFFFFFFF
local BITS_PER_BYTE = 8
local MD5_BLOCK_SIZE = 64
local PADDING_BYTE = string.char(128)
local NULL_BYTE = string.char(0)

local function tobit(n: number)
	return n <= 0x7fffffff and n or -(bit32.bnot(n) + 1)
end

local function normalize(f)
	return function(a, b)
		return tobit(f(tobit(a), tobit(b)))
	end
end

local bor = normalize(bit32.bor)
local band = normalize(bit32.band)
local bxor = normalize(bit32.bxor)
local rshift = normalize(bit32.rshift)
local lshift = normalize(bit32.lshift)

local function lei2str(i)
	local t = {
		string.char(band(i, BYTE_MASK)),
		string.char(band(rshift(i, 8), BYTE_MASK)),
		string.char(band(rshift(i, 16), BYTE_MASK)),
		string.char(band(rshift(i, 24), BYTE_MASK))
	}
	return table.concat(t)
end

local function str2bei(s)
	local v = 0
	for i = 1, #s do
		v = v * 256 + s:byte(i)
	end
	return v
end

local function str2lei(s)
	local v = 0
	for i = #s, 1, -1 do
		v = v * 256 + s:byte(i)
	end
	return v
end

local function cut_le_str(s)
	local t = {}
	for i = 1, #s, 4 do
		t[#t + 1] = str2lei(s:sub(i, i + 3))
	end
	return t
end

local Constants = {
	0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
	0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
	0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
	0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
	0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
	0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
	0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
	0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
	0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
	0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
	0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
	0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
	0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
	0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
	0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
	0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
	0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
}

local function f(x, y, z) return bor(band(x, y), band(bxor(x, WORD_MASK), z)) end

local function g(x, y, z) return bor(band(x, z), band(y, bxor(z, WORD_MASK))) end

local function h(x, y, z) return bxor(x, bxor(y, z)) end

local function i(x, y, z) return bxor(y, bor(x, bxor(z, WORD_MASK))) end

local function z(func, a, b, c, d, x, s, ac)
	a = band(a + func(b, c, d) + x + ac, WORD_MASK)
	return bor(lshift(band(a, 2^s - 1), s), rshift(a, 32 - s)) + b
end

local function transform(A, B, C, D, X)
	local a, b, c, d = A, B, C, D

	a = z(f, a, b, c, d, X[ 0],  7, Constants[ 1])
	d = z(f, d, a, b, c, X[ 1], 12, Constants[ 2])
	c = z(f, c, d, a, b, X[ 2], 17, Constants[ 3])
	b = z(f, b, c, d, a, X[ 3], 22, Constants[ 4])
	a = z(f, a, b, c, d, X[ 4],  7, Constants[ 5])
	d = z(f, d, a, b, c, X[ 5], 12, Constants[ 6])
	c = z(f, c, d, a, b, X[ 6], 17, Constants[ 7])
	b = z(f, b, c, d, a, X[ 7], 22, Constants[ 8])
	a = z(f, a, b, c, d, X[ 8],  7, Constants[ 9])
	d = z(f, d, a, b, c, X[ 9], 12, Constants[10])
	c = z(f, c, d, a, b, X[10], 17, Constants[11])
	b = z(f, b, c, d, a, X[11], 22, Constants[12])
	a = z(f, a, b, c, d, X[12],  7, Constants[13])
	d = z(f, d, a, b, c, X[13], 12, Constants[14])
	c = z(f, c, d, a, b, X[14], 17, Constants[15])
	b = z(f, b, c, d, a, X[15], 22, Constants[16])

	a = z(g, a, b, c, d, X[ 1],  5, Constants[17])
	d = z(g, d, a, b, c, X[ 6],  9, Constants[18])
	c = z(g, c, d, a, b, X[11], 14, Constants[19])
	b = z(g, b, c, d, a, X[ 0], 20, Constants[20])
	a = z(g, a, b, c, d, X[ 5],  5, Constants[21])
	d = z(g, d, a, b, c, X[10],  9, Constants[22])
	c = z(g, c, d, a, b, X[15], 14, Constants[23])
	b = z(g, b, c, d, a, X[ 4], 20, Constants[24])
	a = z(g, a, b, c, d, X[ 9],  5, Constants[25])
	d = z(g, d, a, b, c, X[14],  9, Constants[26])
	c = z(g, c, d, a, b, X[ 3], 14, Constants[27])
	b = z(g, b, c, d, a, X[ 8], 20, Constants[28])
	a = z(g, a, b, c, d, X[13],  5, Constants[29])
	d = z(g, d, a, b, c, X[ 2],  9, Constants[30])
	c = z(g, c, d, a, b, X[ 7], 14, Constants[31])
	b = z(g, b, c, d, a, X[12], 20, Constants[32])

	a = z(h, a, b, c, d, X[ 5],  4, Constants[33])
	d = z(h, d, a, b, c, X[ 8], 11, Constants[34])
	c = z(h, c, d, a, b, X[11], 16, Constants[35])
	b = z(h, b, c, d, a, X[14], 23, Constants[36])
	a = z(h, a, b, c, d, X[ 1],  4, Constants[37])
	d = z(h, d, a, b, c, X[ 4], 11, Constants[38])
	c = z(h, c, d, a, b, X[ 7], 16, Constants[39])
	b = z(h, b, c, d, a, X[10], 23, Constants[40])
	a = z(h, a, b, c, d, X[13],  4, Constants[41])
	d = z(h, d, a, b, c, X[ 0], 11, Constants[42])
	c = z(h, c, d, a, b, X[ 3], 16, Constants[43])
	b = z(h, b, c, d, a, X[ 6], 23, Constants[44])
	a = z(h, a, b, c, d, X[ 9],  4, Constants[45])
	d = z(h, d, a, b, c, X[12], 11, Constants[46])
	c = z(h, c, d, a, b, X[15], 16, Constants[47])
	b = z(h, b, c, d, a, X[ 2], 23, Constants[48])

	a = z(i, a, b, c, d, X[ 0],  6, Constants[49])
	d = z(i, d, a, b, c, X[ 7], 10, Constants[50])
	c = z(i, c, d, a, b, X[14], 15, Constants[51])
	b = z(i, b, c, d, a, X[ 5], 21, Constants[52])
	a = z(i, a, b, c, d, X[12],  6, Constants[53])
	d = z(i, d, a, b, c, X[ 3], 10, Constants[54])
	c = z(i, c, d, a, b, X[10], 15, Constants[55])
	b = z(i, b, c, d, a, X[ 1], 21, Constants[56])
	a = z(i, a, b, c, d, X[ 8],  6, Constants[57])
	d = z(i, d, a, b, c, X[15], 10, Constants[58])
	c = z(i, c, d, a, b, X[ 6], 15, Constants[59])
	b = z(i, b, c, d, a, X[13], 21, Constants[60])
	a = z(i, a, b, c, d, X[ 4],  6, Constants[61])
	d = z(i, d, a, b, c, X[11], 10, Constants[62])
	c = z(i, c, d, a, b, X[ 2], 15, Constants[63])
	b = z(i, b, c, d, a, X[ 9], 21, Constants[64])

	return bit32.band(A + a, WORD_MASK), bit32.band(B + b, WORD_MASK), bit32.band(C + c, WORD_MASK), bit32.band(D + d, WORD_MASK)
end

function md5._update(self, s)
	local pos = self.pos
	local buf = self.buf
	pos = pos + #s
	s = buf .. s
	
	local len = #s
	local blockCount = math.floor(len / MD5_BLOCK_SIZE)
	
	for i = 1, blockCount * MD5_BLOCK_SIZE, MD5_BLOCK_SIZE do
		local x = cut_le_str(s:sub(i, i + MD5_BLOCK_SIZE - 1))
		assert(#x == 16)
		x[0] = table.remove(x, 1)
		self.a, self.b, self.c, self.d = transform(self.a, self.b, self.c, self.d, x)
	end
	
	self.pos = pos
	self.buf = s:sub(blockCount * MD5_BLOCK_SIZE + 1, len)
	return self
end

function md5._finish(self)
	local msgLen = self.pos
	local padLen = 56 - msgLen % MD5_BLOCK_SIZE

	if msgLen % MD5_BLOCK_SIZE > 56 then 
		padLen = padLen + MD5_BLOCK_SIZE 
	end
	if padLen == 0 then 
		padLen = MD5_BLOCK_SIZE 
	end

	local lowBits = lei2str(bit32.band(BITS_PER_BYTE * msgLen, WORD_MASK))
	local highBits = lei2str(math.floor(msgLen / 0x20000000))
	
	local padding = PADDING_BYTE .. string.rep(NULL_BYTE, padLen - 1)
	md5._update(self, padding .. lowBits .. highBits)

	assert(self.pos % MD5_BLOCK_SIZE == 0)
	return lei2str(self.a) .. lei2str(self.b) .. lei2str(self.c) .. lei2str(self.d)
end

type MD5State = {
	a: number,
	b: number,
	c: number,
	d: number,
	pos: number,
	buf: string,
	update: (self: MD5State, s: string) -> MD5State,
	finish: (self: MD5State) -> string
}

function md5.new(): MD5State
	return {
		a = Constants[65],
		b = Constants[66],
		c = Constants[67],
		d = Constants[68],
		pos = 0,
		buf = "",
		update = md5._update,
		finish = md5._finish
	}
end

function md5.tohex(s)
	return string.format(
		"%08x%08x%08x%08x",
		str2bei(s:sub(1, 4)),
		str2bei(s:sub(5, 8)),
		str2bei(s:sub(9, 12)),
		str2bei(s:sub(13, 16))
	)
end

function md5.sum(s)
	return md5.new():update(s):finish()
end

function md5.sumhexa(s)
	return md5.tohex(md5.sum(s))
end

return md5