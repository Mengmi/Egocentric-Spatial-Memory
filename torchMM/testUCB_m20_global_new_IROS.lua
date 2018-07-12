require 'mobdebug'.start()
require 'cutorch'
require 'cunn'
require 'nn'
require 'nngraph'
require 'optim'
require 'image'
require 'stn'
local model_utils=require 'model_utils'
--local mnist = require 'mnist'
local matio = require 'matio'

nngraph.setDebug(true)

function WriteGif(filename, movie)
  for fr=1,movie:size(2) do
    image.save(filename .. '.' ..  string.format('%08d', fr) .. '.png', image.toDisplayTensor(movie:select(2,fr)))
  end
  cmd = "ffmpeg -f image2 -r 2 -i " .. filename .. ".%08d.png -y " .. filename
  print('==> ' .. cmd)
  sys.execute(cmd)
  for fr=1,movie:size(2) do
    os.remove(filename .. '.' .. string.format('%08d', fr) .. '.png')
  end
end

GlobalSize = 500 --500
seq_length = 32
A = 32
n_data = 10 --batchsize
n_channel = 3
totalIter = 40 --depends on total Num Img/n_data
transScale = 1.95 --2*250/256 --750*2/256 --1.95
seqlengthlist =  {50,40,50,50,40,40,67,67,67}
FW = 128*2 --16*2

--encoder = torch.load('encoder.t7')
--decoder = torch.load('decoder.t7')
encoder = torch.load('../models/ucb_m18_IROS/iter_15000.t7')
encoder = encoder:cuda()
print('loaded models')


----------------------------global mapper------------------------------------------------
outputencoder = nn.Sequential()
outputencoder:add(nn.Reshape(1,GlobalSize,GlobalSize))

------------------------------get previous global map
transferbr1 = nn.Sequential()
transferbr1: add(nn.Reshape(1,2,3))
transferbr1: add(nn.AffineGridGeneratorBHWD(GlobalSize, GlobalSize))

transferbr2 = nn.Sequential()
transferbr2: add(nn.Reshape(1, 1, GlobalSize, GlobalSize))
transferbr2: add(nn.Transpose({3,4},{2,4}))

transferPara = nn.ParallelTable()
transferPara:add(transferbr2)
transferPara:add(transferbr1)

transferT = nn.Sequential()
transferT:add(transferPara)
transferT:add(nn.BilinearSamplerBHWD())
transferT:add(nn.Transpose({2,4},{3,4}))
transferT:add(nn.Reshape(1, GlobalSize, GlobalSize))
transferT:add(nn.ReLU())

------------------------------ final summation

combinePara = nn.ParallelTable()
combinePara:add(transferT)
combinePara:add(outputencoder)

combine = nn.Sequential()
combine:add(combinePara)
combine:add(nn.CAddTable())
combine:add(nn.Reshape(GlobalSize, GlobalSize))

combine:add(nn.HardTanh())
combine = combine:cuda()
----------------------------global mapper------------------------------------------------

for w = 5, 5 do

	worldnum = 5
	framenum = 1
	framestop = 3027

        trainrelative = torch.load('../datalist/IROStestrelative_global_w' .. worldnum)
        trainrelative = trainrelative[1]


	predpose = torch.load('../datalist/IROStestposeindex_global_w' ..  worldnum )
	--predpose = predpose['x'] --size: 32 by 10

	img_input = torch.zeros(n_data, n_channel, A, A)
	obj_inputprev = torch.zeros(n_data, A, A)
	tfcompose = torch.zeros(n_data, 2, 3)
	obj_inputprev = torch.zeros(n_data, A, A)

	global = torch.zeros(GlobalSize,GlobalSize)
	global_prev = torch.zeros(GlobalSize,GlobalSize)
	global_out = torch.zeros(GlobalSize,GlobalSize)

	print('world: ' ..worldnum)

	for j = 1,framestop do    

            act = predpose[1][1][j]
            --print('mengmi check')
            --print(act)
	    temptf = matio.load('../datalist/IROSTransForm_' .. act .. '.mat')
	    temptf = temptf['tf']
 
	--print('2: ' ..j)
	    for k = 1, n_data do 
		    --print('3: ' .. k)
		    --print('4: ' .. k+ (period-1)*n_data)
		    
		    imgname = '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' .. worldnum .. '/camera_wd/camera_' .. j .. '.jpg'
		    img = image.load(imgname)
		    img = image.scale(img, A,A)
		    img_input[{{k},{}, {}, {}}] = img
		    
		    --[[objname = '/data/mengmi/3dDatabase/Nav3D/World' .. worldnum .. '/map_global/map_' .. (framenum) .. '_' .. (j-1) .. '.jpg'
		    img = image.load(objname)
		    img = image.scale(img, A,A)
		    obj_inputprev[{{k},{}, {}}] = img]]--

		    

		    --[[if act == 5 then
                    print(temptf)
                    end
		    if act == 6 then
                    print(temptf)
                    end]]--
                    --temptf[1][3] = temptf[1][3]*4.5 
                    --temptf[2][3] = temptf[2][3]*4.5

                    --tfcompose[{{k},{}, {}}] = trainrelative[{{},{  (3*(j-1)+1),(3*(j-1)+3) }}]
		    tfcompose[{{k},{}, {}}] = temptf
		   
	    end

	    --print(tfcompose[{{1},{}, {}}])
	    x = img_input:cuda()
	    x3dprev = obj_inputprev:cuda()
	    tfprev = tfcompose:cuda()

	    output = encoder:forward( x)
	    output = output:double()
	    obj_inputprev = output    
	    
            --resizepostoutput = nn.Threshold(0.5, 0):forward(output[1])
	    resizepostoutput = image.scale(output[1],256,256)  
	    --print(resizepostoutput:size())
	    
            --imgname = '../results/MatFormat/predicted_ucb20gAthin_' .. j .. '_w' .. worldnum .. '.jpg'
	    --img = image.load(imgname)
            --resizepostoutput = img
	 
	    globaltfprev = tfcompose[1]
	    globaltfprev[1][3] = globaltfprev[1][3]/transScale
	    globaltfprev[2][3] = globaltfprev[2][3]/transScale
	    --tfselect[{{1},{},{}}] = tfprev[1]
	    tempglobalL = torch.zeros(GlobalSize,GlobalSize)
	    tempglobalL[{   {GlobalSize/2 - FW/2,GlobalSize/2 + FW/2 - 1}, {GlobalSize/2 - FW/2,GlobalSize/2 + FW/2 - 1}   }] = resizepostoutput
            --tempglobalL[{   {GlobalSize/2 - FW/2,GlobalSize/2 + FW/2 - 1}, {GlobalSize/2 - FW/2,GlobalSize/2 + FW/2 - 1}   }] = output[1]
	    global_out = combine:forward( {{global_prev:cuda(),globaltfprev:cuda()}, tempglobalL:cuda()})
	    global_prev  = global_out[1]
	    global = global_out[1]:double()


	    savefile =  '/media/mengmi/TOSHIBA EXT/3DGAN/IROSresults/TBworld5/predicted_ucb20g_' .. j .. '.mat'
	    matio.save(savefile,global)
            collectgarbage()
	    print('finish one iter: ' .. j)

	end
end


