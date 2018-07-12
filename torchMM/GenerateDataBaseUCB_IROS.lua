require 'mobdebug'.start()
require 'cutorch'
require 'cunn'
require 'nn'
require 'nngraph'
require 'optim'
require 'image'
local model_utils=require 'model_utils'
local matio = require 'matio'
matio.use_lua_strings = true --flag set
nngraph.setDebug(true)

--trainposeindex

trainbinlist = matio.load('../datalist/IROStrainframelist.mat')
trainbinlist = trainbinlist['trainframelist']
trainimglist = matio.load('../datalist/IROStrainrelative.mat')
trainimglist = trainimglist['trainrelative']
trainmaplist = matio.load('../datalist/IROStrainworldlist.mat')
trainmaplist = trainmaplist['trainworldlist']
trainposeindex = matio.load('../datalist/IROStrainposeindex.mat')
trainposeindex = trainposeindex['trainposeindex']

torch.save('../datalist/IROStrainframelist',trainbinlist)
torch.save('../datalist/IROStrainrelative',trainimglist)
torch.save('../datalist/IROStrainworldlist',trainmaplist)
torch.save('../datalist/IROStrainposeindex',trainposeindex)
print('done')

--testposeindex
for i = 5 ,  5 do

        trainimglist = matio.load('../datalist/IROStestworldlist_w' .. i .. '.mat')
	trainimglist = trainimglist['testworldlist']
	torch.save('../datalist/IROStestworldlist_w' .. i ,trainimglist)

	trainimglist = matio.load('../datalist/IROStestframelist_w' .. i .. '.mat')
	trainimglist = trainimglist['testframelist']
	torch.save('../datalist/IROStestframelist_w' .. i,trainimglist)

	trainimglist = matio.load('../datalist/IROStestrelative_w' .. i .. '.mat')
	trainimglist = trainimglist['testrelative']
	torch.save('../datalist/IROStestrelative_w' .. i,trainimglist)

	trainimglist = matio.load('../datalist/IROStestposeindex_w' .. i .. '.mat')
	trainimglist = trainimglist['testposeindex']
	torch.save('../datalist/IROStestposeindex_w' .. i,trainimglist)

        trainimglist = matio.load('../datalist/IROStestrelative_global_w' .. i .. '.mat')
	trainimglist = trainimglist['testrelative']
	torch.save('../datalist/IROStestrelative_global_w' ..i ,trainimglist)

        trainimglist = matio.load('../datalist/IROStestposeindex_global_w' .. i .. '.mat')
	trainimglist = trainimglist['testposeindex']
	torch.save('../datalist/IROStestposeindex_global_w' ..i,trainimglist)

end

--[[
--trainbinlist = matio.load('../datalist/testframelist.mat')
--trainbinlist = trainbinlist['testframelist']
trainimglist = matio.load('../datalist/testrelative.mat')
trainimglist = trainimglist['testrelative']
--trainmaplist = matio.load('../datalist/testworldlist.mat')
--trainmaplist = trainmaplist['testworldlist']
testposeindex = matio.load('../datalist/testposeindex.mat')
testposeindex = testposeindex['testposeindex']


--torch.save('../datalist/testframelist',trainbinlist)
torch.save('../datalist/testrelative',trainimglist)
--torch.save('../datalist/testworldlist',trainmaplist)
torch.save('../datalist/testposeindex',testposeindex)


trainimglist = matio.load('../datalist/testrelative_global_w8.mat')
trainimglist = trainimglist['testrelative']
torch.save('../datalist/testrelative_global_w8',trainimglist)

trainimglist = matio.load('../datalist/testrelative_global_w9.mat')
trainimglist = trainimglist['testrelative']
torch.save('../datalist/testrelative_global_w9',trainimglist)

trainimglist = matio.load('../datalist/testrelative_global_w10.mat')
trainimglist = trainimglist['testrelative']
torch.save('../datalist/testrelative_global_w10',trainimglist)

trainimglist = matio.load('../datalist/testposeindex_global_w10.mat')
trainimglist = trainimglist['testposeindex']
torch.save('../datalist/testposeindex_global_w10',trainimglist)

--------- 32 sequences
trainimglist = matio.load('../datalist/testworldlist_w10.mat')
trainimglist = trainimglist['testworldlist']
torch.save('../datalist/testworldlist_w10',trainimglist)

trainimglist = matio.load('../datalist/testframelist_w10.mat')
trainimglist = trainimglist['testframelist']
torch.save('../datalist/testframelist_w10',trainimglist)

trainimglist = matio.load('../datalist/testrelative_w10.mat')
trainimglist = trainimglist['testrelative']
torch.save('../datalist/testrelative_w10',trainimglist)

trainimglist = matio.load('../datalist/testposeindex_w10.mat')
trainimglist = trainimglist['testposeindex']
torch.save('../datalist/testposeindex_w10',trainimglist)

-- world 9
trainimglist = matio.load('../datalist/testworldlist_w9.mat')
trainimglist = trainimglist['testworldlist']
torch.save('../datalist/testworldlist_w9',trainimglist)

trainimglist = matio.load('../datalist/testframelist_w9.mat')
trainimglist = trainimglist['testframelist']
torch.save('../datalist/testframelist_w9',trainimglist)

trainimglist = matio.load('../datalist/testrelative_w9.mat')
trainimglist = trainimglist['testrelative']
torch.save('../datalist/testrelative_w9',trainimglist)

trainimglist = matio.load('../datalist/testposeindex_w9.mat')
trainimglist = trainimglist['testposeindex']
torch.save('../datalist/testposeindex_w9',trainimglist)]]--


--imgname = trainbinlist[1]
print('done')
