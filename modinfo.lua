return {
	name = 'Zero-K with Unit Sizes',
	description = 'Zero-K with multiple size variants of most units',
	shortname = 'unitsizes',
	version = 'v0.1.0',
	mutator = '1',
	game = 'Zero-K',
	shortGame = 'ZK',
	modtype = 1,
	depend = {
		--[[rapid://zk:stable]]
		--[[rapid://zk:latest]]
		'Zero-K $VERSION'
	},
}