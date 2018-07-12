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

--total number per world: 1521

matio.use_lua_strings = true --flag set
nngraph.setDebug(true)
--total train image: 137830; test image: 34188
----------------------- define all the pathways ------------------------------------
model_prefix = '../models/triplet_m7/'
model_name = 'iter_'
history_name = 'hist_'
saving_everymodel = 5000 -- save model every x iterations
saving_everyhistory = 10 -- save history every x iterations
lr_decay = 15000         -- how often to decay learning rate
lr = 2e-4 --learning rate
momentum = 0.5 --momentum
epoch = 15 --stop after this iter
texture = 3
digits = 9
preloadad = '../models/triplet_m7/iter_25000'
preloadedhist = '../models/triplet_m7/hist_25000'
load = 1 --load model
cutorch.setDevice(1) --gpu id selection

n_channel = 3 -- channels of nautral images RGB
A = 128 -- width/height of image
n_data = 10 -- batch size
------------------------------------------------------------------------------------

print('loading pre-trained model')        
tripmodel  = torch.load(preloadad .. '.t7')     
tripmodel = tripmodel:cuda()     

--train
print('Model setup complete')

anchor = torch.zeros(n_data, n_channel, A, A)
similar = torch.zeros(n_data, n_channel, A, A)
disimilar = torch.zeros(n_data, n_channel, A, A)
print('Input complete')


------------------------------------------------------------------------
-- optimization loop
--
optim_state = {learningRate = lr, beta1 = momentum, } --lr and momentum
params, grad_params = tripmodel:getParameters()

totaliter = 0
comparedim = 430
loss = torch.zeros(comparedim,comparedim)

for time  = 1, comparedim do

          print('iter: ' .. time)

	  prefixanchor = '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/World9/camera_temp/camera_' .. time .. '.jpg'
          animg = image.load(prefixanchor)
	  animg = image.scale(animg, A,A)

  for j = 1, comparedim/n_data do

          print('inside: ' .. j)
          for b = 1, n_data do
		  prefixsmilar = '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/World9/camera_temp/camera_' .. (j-1)*n_data+b .. '.jpg'
		  prefixdisimi = '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/World9/camera_temp/camera_' .. (j-1)*n_data+b .. '.jpg'
		  
		  siimg = image.load(prefixsmilar)
		  siimg = image.scale(siimg, A,A)

		  disimg = image.load(prefixdisimi)
		  disimg = image.scale(disimg, A,A)

		  anchor[{{b},{},{},{}}] = animg
		  similar[{{b},{},{},{}}] = siimg
		  disimilar[{{b},{},{},{}}] = disimg
          end

          ------------------- forward pass -------------------  
  	  
  	  an = anchor:cuda()
  	  si = similar:cuda()
  	  di = disimilar:cuda()

          --{1 : CudaTensor - size: 10;  2 : CudaTensor - size: 10}

  	  output = tripmodel:forward({si, an, di})
          
          for b = 1, n_data do
          	loss[time][(j-1)*n_data+b] = output[1][b]
          end
  end
 	  
end

savefile = '../results/MatFormat/loss_triplet7.mat'
matio.save(savefile,loss)

print('Sucessfully saved!')

os.exit()
