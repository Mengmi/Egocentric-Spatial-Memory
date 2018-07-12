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
model_prefix = '../models/ucb_m20_IROS/'
model_name = 'iter_'
history_name = 'hist_'
saving_everymodel = 2500 -- save model every x iterations
saving_everyhistory = 10 -- save history every x iterations
lr_decay = 500         -- how often to decay learning rate
lr = 1e-3 --learning rate
momentum = 0.5 --momentum
totaliter = 7500 --stop after this iter
preloadad = '/data/mengmi/models/ucb_m20_new/iter_1000'
preloadedhist = '/data/mengmi/models/ucb_m20/hist_1000'
loadStream = '../models/ucb_m18_IROS/iter_15000.t7'
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
	encoder = torch.load(loadStream)
        encoder:add(nn.ReLU())

        ------------------------------get previous global map
        transferbr1 = nn.Sequential()
        transferbr1: add(nn.AffineGridGeneratorBHWD(A, A))
 
        transferbr2 = nn.Sequential()
        transferbr2: add(nn.Reshape(n_data, 1, A, A))
        transferbr2: add(nn.Transpose({3,4},{2,4}))

        transferPara = nn.ParallelTable()
        transferPara:add(transferbr2)
        transferPara:add(transferbr1)

        transferT = nn.Sequential()
        transferT:add(transferPara)
        transferT:add(nn.BilinearSamplerBHWD())
        transferT:add(nn.Transpose({2,4},{3,4}))
        transferT:add(nn.Reshape(n_data, A, A))
        transferT:add(nn.ReLU())

        ------------------------------ final summation
        
        combinePara = nn.ParallelTable()
        combinePara:add(transferT)
        combinePara:add(encoder)

        combine = nn.Sequential()
        combine:add(combinePara)
        combine:add(nn.CAddTable())
        

        combine:add(nn.HardTanh())
        --combine:add(nn.Threshold(0.99, 0))
	combine = combine:cuda()

        paths.mkdir(model_prefix)
        torch.save(model_prefix .. model_name .. 0 .. '.t7', combine:clearState())  

print('encoder ready!')

history = {}

else
     print('loading pre-trained model')        
     combine  = torch.load(preloadad .. '.t7')     
     history = torch.load(preloadedhist .. '.t7') 

     combine = combine:cuda()     
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

trainworldlist = torch.load('../datalist/trainworldlist')
trainrelative = torch.load('../datalist/trainrelative')
trainframelist = torch.load('../datalist/trainframelist')

local imglist 
local objlist 
local tflist

img_input = torch.zeros(n_data, n_channel, A, A)
obj_input = torch.zeros(n_data, A, A)
obj_inputprev = torch.zeros(n_data, A, A)
tfcompose = torch.zeros(n_data, 2, 3)

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
    x3dprev = obj_inputprev:cuda()
    tfprev = tfcompose:cuda()

    --print('start forward')
    output = combine:forward( {{x3dprev,tfprev}, x})
    --print('end forward')
    loss = criterion:forward(output, x3d)
    --print('criterian forward')
    local df = criterion:backward(output, x3d)
    --print('df forward')
    combine:backward({{x3dprev,tfprev}, x}, df)
    --print('backward done')
    return loss, grad_params
end

------------------------------------------------------------------------
-- optimization loop
--
optim_state = {learningRate = lr, beta1 = momentum, } --lr and momentum
params, grad_params = combine:getParameters()

for i = 1, totaliter do
 
  period = i%(#trainworldlist) + 1
  --print('1: ' .. period)
  if period <= (#trainworldlist-n_data+1) then

	  imglist = torch.load('/data/mengmi/3dDatabase/Nav3D/All/all_img_input_'.. period .. '.t7')
          objlist = torch.load('/data/mengmi/3dDatabase/Nav3D/All/all_obj_input_'.. period .. '.t7')
          tflist = torch.load('/data/mengmi/3dDatabase/Nav3D/All/all_tfcompose_'.. period .. '.t7')

          for t = 2, seq_length do

          	if t == 1 then
		  img_input = imglist[t]
		  obj_inputprev = zeros(n_data, A, A)
		  obj_input = objlist[t]
                  tfcompose = tflist[t]
		else
		  img_input = imglist[t]
		  obj_input = objlist[t]
                  obj_inputprev = objlist[t-1]
		  tfcompose = tflist[t]
		end

		--print('prepared data')
		optim.adam(feval, params, optim_state)
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
     torch.save(model_prefix .. model_name .. i .. '.t7', combine:clearState())     
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
torch.save(model_prefix .. model_name .. totaliter .. '.t7', combine:clearState())


print('Sucessfully trained and tested! Bye!')
os.exit()
