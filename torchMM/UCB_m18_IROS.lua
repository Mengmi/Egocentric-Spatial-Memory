--require 'mobdebug'.start()
require 'cutorch'
require 'cunn'
require 'nn'
require 'nngraph'
require 'optim'
require 'image'
require 'stn'
local matio = require 'matio'
local model_utils=require 'model_utils'

matio.use_lua_strings = true --flag set
nngraph.setDebug(true)
--total train image: 137830; test image: 34188
----------------------- define all the pathways ------------------------------------
model_prefix = '../models/ucb_m18_IROS/'
model_name = 'iter_'
history_name = 'hist_'
saving_everymodel = 150000 -- save model every x iterations
saving_everyhistory = 1000 -- save history every x iterations
lr_decay = 15000         -- how often to decay learning rate
lr = 2e-3 --learning rate
momentum = 0.5 --momentum
totaliter = 150000 --stop after this iter
loadStream = '../models/ucb_m18_new/iter_30000.t7'
preloadedhist = '/data/mengmi/models/ucb_m18/hist_1000'
load = 0 --load model
cutorch.setDevice(1) --gpu id selection

seq_length = 32 --number of fixations
n_channel = 3 -- channels of nautral images RGB
A = 32 -- width/height of image
n_data = 10 -- batch size
------------------------------------------------------------------------------------

print('start program')

if load == 0 then

        ----------------------------encode current part
	encoder = nn.Sequential()
        encoder:add(nn.SpatialConvolution(3,128, 4,4, 2,2, 1,1))
	encoder:add(nn.ReLU(true))
	encoder:add(nn.SpatialConvolution(128,256, 4,4, 2,2, 1,1))
	encoder:add(nn.SpatialBatchNormalization(256,1e-3)):add(nn.ReLU(true))
	encoder:add(nn.SpatialConvolution(256,512, 4,4, 2,2, 1,1))
	encoder:add(nn.SpatialBatchNormalization(512,1e-3)):add(nn.ReLU(true))
        encoder:add(nn.SpatialConvolution(512,1024, 4,4, 2,2, 1,1))
	encoder:add(nn.SpatialBatchNormalization(1024,1e-3)):add(nn.ReLU(true))

        --module = nn.SpatialFullConvolution(nInputPlane, nOutputPlane, kW, kH, [dW], [dH], [padW], [padH], [adjW], [adjH])
        encoder:add(nn.SpatialFullConvolution(1024,512, 4,4, 2,2, 1,1))
	encoder:add(nn.SpatialBatchNormalization(512,1e-3)):add(nn.ReLU(true))
	encoder:add(nn.SpatialFullConvolution(512,256, 4,4, 2,2, 1,1))
	encoder:add(nn.SpatialBatchNormalization(256,1e-3)):add(nn.ReLU(true))
	encoder:add(nn.SpatialFullConvolution(256,128, 4,4, 2,2, 1,1))
	encoder:add(nn.SpatialBatchNormalization(128,1e-3)):add(nn.ReLU(true))
	encoder:add(nn.SpatialFullConvolution(128,1, 4,4, 2,2, 1,1))
	encoder:add(nn.SpatialBatchNormalization(1,1e-3)):add(nn.ReLU(true))

        encoder:add(nn.Squeeze())
	encoder:add(nn.View(n_data, A,A)) 

        encoder = encoder:cuda()


        --uncomment this if want to load from pre-trained model in maze datasets
        --encoder  = torch.load(loadStream)
        --encoder = encoder:cuda()
 

print('encoder ready!')

history = {}

else
     print('loading pre-trained model')        
     encoder  = torch.load(loadStream)     
     history = {}--torch.load(preloadedhist .. '.t7') 

     encoder = encoder:cuda()     
end

--encoder_clones = model_utils.clone_many_times(encoder, seq_length)

--local criterion = nn.DistKLDivCriterion()
--criterion = criterion:cuda()

--local criterion = nn.CrossEntropyCriterion()
--criterion = criterion:cuda()


local loss = -1
local criterion = nn.MSECriterion()
criterion = criterion:cuda()

--train
print('Model setup complete')

trainworldlist = torch.load('../datalist/IROStrainworldlist')
trainrelative = torch.load('../datalist/IROStrainrelative')
trainframelist = torch.load('../datalist/IROStrainframelist')

local imglist 
local objlist 
local tflist

img_input = torch.zeros(n_data, n_channel, A, A)
obj_input = torch.zeros(n_data, A, A)

print('Input complete')

-- do fwd/bwd and return loss, grad_params
function feval(x_arg)
    if x_arg ~= params then
        params:copy(x_arg)
    end
    grad_params:zero()
    
    ------------------- forward pass -------------------
    
    --print('input done')
    loss = 0
    x = img_input:cuda()
    x3d = obj_input:cuda()
    
    --print('start forward')
    output = encoder:forward(x)
    --print('end forward')
    loss = criterion:forward(output, x3d)
    --print('criterian forward')
    local df = criterion:backward(output, x3d)
    --print('df forward')
    encoder:backward(x, df)
    --print('backward done')
    return loss, grad_params
end

------------------------------------------------------------------------
-- optimization loop
--
optim_state = {learningRate = lr, beta1 = momentum, } --lr and momentum
params, grad_params = encoder:getParameters()

for i = 10984, totaliter do
 
  period = i%(#trainworldlist) + 1
  print(string.format("iteration %4d, loss = %6.6f", i, loss))
  if period <= (#trainworldlist-n_data+1) then

	  imglist = torch.load('/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/All_IROS/all_img_input_'.. period .. '.t7')
          objlist = torch.load('/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/All_IROS/all_obj_local_input_'.. period .. '.t7')
          --tflist = torch.load('/data/mengmi/3dDatabase/Nav3D/All/all_tfcompose_'.. period .. '.t7')

          for t = 1, seq_length do

          	img_input = imglist[t]
		obj_input = objlist[t]

		--print('prepared data')
		--optim.adam(feval, params, optim_state)
		--print('done one iter')
	  end
  end

  if i % saving_everyhistory == 0 then
      table.insert(history, {loss})
      print(string.format("iteration %4d, loss = %6.6f", i, loss))
      --print(params)      
  end

  if i% saving_everymodel == 0 then
     print('saving: '.. i)
     paths.mkdir(model_prefix)
     torch.save(model_prefix .. history_name .. i .. '.t7', history)
     torch.save(model_prefix .. model_name .. i .. '.t7', encoder:clearState())     
  end

  if lr_decay > 0 and i % lr_decay == 0 then
    lr = lr / 10
    print('Decreasing learning rate to ' .. lr)

    -- create new optim_state to reset momentum
    optim_state = {
      learningRate = lr,
      beta1 = momentum,
    }
  end

  collectgarbage()
end
print('Sucessfully saved!')
paths.mkdir(model_prefix)
torch.save(model_prefix .. history_name .. totaliter .. '.t7', history)
torch.save(model_prefix .. model_name .. totaliter .. '.t7', encoder:clearState())


print('Sucessfully trained and tested! Bye!')
os.exit()
