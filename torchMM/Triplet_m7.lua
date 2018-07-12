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
model_prefix = '/data/mengmi/models/triplet_m7/'
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
preloadad = '/data/mengmi/models/triplet_m7/iter_1651'
preloadedhist = '/data/mengmi/models/triplet_m7/hist_1651'
load = 0 --load model
cutorch.setDevice(1) --gpu id selection

n_channel = 3 -- channels of nautral images RGB
A = 128 -- width/height of image
n_data = 10 -- batch size
------------------------------------------------------------------------------------

print('start program')

if load == 0 then

	encoder = nn.Sequential()
        encoder:add(nn.SpatialConvolution(3,64, 4,4, 2,2, 1,1))        
        encoder:add(nn.SpatialBatchNormalization(64,1e-3))
	encoder:add(nn.ReLU(true))
        encoder:add(nn.SpatialConvolution(64,64, 3,3, 1,1, 1,1))
        encoder:add(nn.SpatialBatchNormalization(64,1e-3))
	encoder:add(nn.ReLU(true))        
        encoder:add(nn.SpatialMaxPooling(2,2,2,2,0,0))
        --module = nn.SpatialMaxPooling(kW, kH [, dW, dH, padW, padH])
    
        encoder:add(nn.SpatialConvolution(64,128, 4,4, 2,2, 1,1))
        encoder:add(nn.SpatialBatchNormalization(128,1e-3))
	encoder:add(nn.ReLU(true))
        encoder:add(nn.SpatialConvolution(128,128, 3,3, 1,1, 1,1))
        encoder:add(nn.SpatialBatchNormalization(128,1e-3))
	encoder:add(nn.ReLU(true))        
        encoder:add(nn.SpatialMaxPooling(2, 2, 2, 2, 0, 0))

        encoder:add(nn.SpatialConvolution(128,256, 3,3, 1,1, 1,1))
        encoder:add(nn.SpatialBatchNormalization(256,1e-3))
	encoder:add(nn.ReLU(true))
        encoder:add(nn.SpatialConvolution(256,256, 3,3, 1,1, 1,1))
        encoder:add(nn.SpatialBatchNormalization(256,1e-3))
	encoder:add(nn.ReLU(true))        
        encoder:add(nn.SpatialMaxPooling(2, 2, 2, 2, 0, 0))

        encoder:add(nn.SpatialConvolution(256,512, 3,3, 1,1, 1,1))
        encoder:add(nn.SpatialBatchNormalization(512,1e-3))
	encoder:add(nn.ReLU(true))
        encoder:add(nn.SpatialConvolution(512,512, 3,3, 1,1, 1,1))
        encoder:add(nn.SpatialBatchNormalization(512,1e-3))
	encoder:add(nn.ReLU(true))        
        encoder:add(nn.SpatialMaxPooling(2, 2, 2, 2, 0, 0))

        --[[encoder:add(nn.SpatialConvolution(512,1024, 3,3, 1,1, 1,1))
        encoder:add(nn.SpatialBatchNormalization(1024,1e-3))
	encoder:add(nn.ReLU(true))
        encoder:add(nn.SpatialConvolution(1024,1024, 3,3, 1,1, 1,1))
        encoder:add(nn.SpatialBatchNormalization(1024,1e-3))
	encoder:add(nn.ReLU(true))        
        encoder:add(nn.SpatialMaxPooling(2, 2, 2, 2, 0, 0))]]--

        encoder:add(nn.View(n_data, -1))
	encoder:add(nn.Linear(4*512,512))  
        encoder:add(nn.ReLU(true)) 
        encoder:add(nn.Linear(512,128))  
        encoder:add(nn.ReLU(true))
        --encoder:add(nn.Linear(1024,128))  
        --encoder:add(nn.ReLU(true))

        tripleModel = nn.ParallelTable()
        tripleModel:add(encoder)
        tripleModel:add(encoder:clone('weight', 'bias', 
                                        'gradWeight', 'gradBias'))
        tripleModel:add(encoder:clone('weight', 'bias',
                                        'gradWeight', 'gradBias'))

        -- Similar sample distance w.r.t anchor sample
        posDistModel = nn.Sequential()
        posDistModel:add(nn.NarrowTable(1,2)):add(nn.PairwiseDistance(1))

        -- Different sample distance w.r.t anchor sample
        negDistModel = nn.Sequential()
        negDistModel:add(nn.NarrowTable(2,2)):add(nn.PairwiseDistance(1))

        distanceModel = nn.ConcatTable():add(posDistModel):add(negDistModel)

        -- Complete Model
        tripmodel = nn.Sequential():add(tripleModel):add(distanceModel)



	tripmodel = tripmodel:cuda()

 

print('tripmodel ready!')

history = {}

else
     print('loading pre-trained model')        
     tripmodel  = torch.load(preloadad .. '.t7')     
     history = torch.load(preloadedhist .. '.t7') 

     tripmodel = tripmodel:cuda()     
end


local loss = -1
local criterion = nn.DistanceRatioCriterion(true)
criterion = criterion:cuda()

--train
print('Model setup complete')

anchor = torch.zeros(n_data, n_channel, A, A)
similar = torch.zeros(n_data, n_channel, A, A)
disimilar = torch.zeros(n_data, n_channel, A, A)
print('Input complete')

-- do fwd/bwd and return loss, grad_params
function feval(x_arg)
    if x_arg ~= params then
        params:copy(x_arg)
    end
    grad_params:zero()
    
    ------------------- forward pass -------------------  
    loss = 0
    an = anchor:cuda()
    si = similar:cuda()
    di = disimilar:cuda()

    --print(an:double():size())
    --output = encoder:forward(an)
    --print(output:double():size())

    --print(an:double():size())
    output = tripmodel:forward({si, an, di})
    --print(output:double():size())


    loss = criterion:forward(output)
    local df = criterion:backward(output)
    tripmodel:backward({si, an, di}, df)

    return loss, grad_params
end

------------------------------------------------------------------------
-- optimization loop
--
optim_state = {learningRate = lr, beta1 = momentum, } --lr and momentum
params, grad_params = tripmodel:getParameters()

totaliter = 0

for time  = 1, epoch do

	for text = 1, texture do --10, 11, 12

	  for num = 1, digits do --1,...,9

		  for batch = 1, 150 do --- 1521/n_data 

		          totaliter = totaliter +1
 
	                  --randomly generate similar set and dissimilar set index
                          digitrandseq = torch.randperm(10)
                          digitseq = torch.linspace(1,10,10)
                          digitseq[num] = 10 --generate random number

                          textseq = torch.randperm(30)%3 + 1 --generate random texture
                          
                          imgrandseq = torch.randperm(1521)

			  for j = 1, n_data do

                                  prefixanchor = '/data/mengmi/3dDatabase/Nav3D/World10_11_12/camera/camera_' .. (text+9) .. '_' .. num .. '_' .. (n_data*(batch-1)+j) .. '.jpg'
				  prefixsmilar = '/data/mengmi/3dDatabase/Nav3D/World10_11_12/camera/camera_' .. (text+9) .. '_' .. num .. '_' .. (imgrandseq[j]) .. '.jpg'
				  prefixdisimi = '/data/mengmi/3dDatabase/Nav3D/World10_11_12/camera/camera_' .. (textseq[j]+9) .. '_' .. digitseq[digitrandseq[j]] .. '_' .. imgrandseq[j] .. '.jpg'
				  
				  animg = image.load(prefixanchor)
		    		  animg = image.scale(animg, A,A)

                                  siimg = image.load(prefixsmilar)
		    		  siimg = image.scale(siimg, A,A)

                                  disimg = image.load(prefixdisimi)
		    		  disimg = image.scale(disimg, A,A)

                                  anchor[{{j},{},{},{}}] = animg
				  similar[{{j},{},{},{}}] = siimg
				  disimilar[{{j},{},{},{}}] = disimg

			  end

			  --print('prepared data')
			  optim.adam(feval, params, optim_state)
			  --print('done one iter')
			 
		  

			  if totaliter % saving_everyhistory == 0 then
			      table.insert(history, {loss})
			      print(string.format("iteration %4d, loss = %6.6f", totaliter, loss))
			      --print(params)      
			  end

			  if totaliter% saving_everymodel == 0 then
			     print('saving: '.. totaliter)
			     paths.mkdir(model_prefix)
			     torch.save(model_prefix .. history_name .. totaliter .. '.t7', history)
			     torch.save(model_prefix .. model_name .. totaliter .. '.t7', tripmodel:clearState())     
			  end

			  if lr_decay > 0 and totaliter % lr_decay == 0 then
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

	  end
	end
end

print('Sucessfully saved!')
paths.mkdir(model_prefix)
torch.save(model_prefix .. history_name .. totaliter .. '.t7', history)
torch.save(model_prefix .. model_name .. totaliter .. '.t7', tripmodel:clearState())


print('Sucessfully trained and tested! Bye!')
os.exit()
