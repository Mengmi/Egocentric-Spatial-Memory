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

seq_length = 32
A = 32
n_data = 10 --batchsize
n_channel = 3
totalIter = 40 --depends on total Num Img/n_data

--encoder = torch.load('encoder.t7')
--decoder = torch.load('decoder.t7')
encoder = torch.load('../models/ucb_m18_IROS/iter_15000.t7')

encoder = encoder:cuda()

print('loaded models')


--trainworldlist = torch.load('../datalist/testworldlist')
--trainrelative = torch.load('../datalist/IROStestrelative_global_w5')
--trainframelist = torch.load('../datalist/testframelist')
print('loaded datasets')


--imglist = {}
--tflist = {}

img_input = torch.zeros(n_data, n_channel, A, A)
--obj_inputprev = torch.zeros(n_data, A, A)
--tfcompose = torch.zeros(n_data, 2, 3)

for i = 1, 1 do
 
          imglist = {}
          objlist = {}
          tflist = {}  

	  for j = 1,3027 do     
	     print('iter: ' ..j)
	    for k = 1, n_data do 
		    --print('3: ' .. k)
		    --print('4: ' .. k+ (period-1)*n_data)
		    worldnum = 5
		    framenum = j
		    --totaltf =trainrelative[1]

		    imgname = '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' .. worldnum .. '/camera_wd/camera_' .. (j) .. '.jpg'
		    img = image.load(imgname)
		    img = image.scale(img, A,A)
		    img_input[{{k},{}, {}, {}}] = img
		    
		    
	    end

	    x = img_input:cuda()	    

	    output = encoder:forward( x)
	    output = output:double()

	    savefile =  '/media/mengmi/TOSHIBA EXT/3DGAN/IROSresults/TBworld5/predicted_ucb20g_' .. j .. '.mat'
	    matio.save(savefile,output)
            
            --savefile = '../results/MatFormat/input_ucb18_' .. i .. '_' .. j .. '.mat'
	    --matio.save(savefile,img_input)

	  end

        print('get inputs from forward')


    ------------------- forward pass -------------------
    
    
	--WriteGif('../results/gif/predicted_ucb7_' .. i ..'.gif', xmovie)


end



