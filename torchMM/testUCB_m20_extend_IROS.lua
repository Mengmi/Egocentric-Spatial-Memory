--require 'mobdebug'.start()
require 'cutorch'
require 'cunn'
require 'nn'
require 'nngraph'
require 'optim'
require 'image'
require 'stn'
--local model_utils=require 'model_utils'
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
totalIter = 299 --depends on total Num Img/n_data
---supposed to be 299 images in TBworld5 but we are using 100 for now

--encoder = torch.load('encoder.t7')
--decoder = torch.load('decoder.t7')
encoder = torch.load('../models/ucb_m20_IROS/iter_0.t7')

encoder = encoder:cuda()

print('loaded models')


trainworldlist = torch.load('../datalist/IROStestworldlist_w5')
trainrelative = torch.load('../datalist/IROStestrelative_w5')
trainframelist = torch.load('../datalist/IROStestframelist_w5')
print('loaded datasets')


--imglist = {}
--tflist = {}
outputsum = torch.zeros(seq_length, n_data, A, A)
img_input = torch.zeros(n_data, n_channel, A, A)
obj_inputprev = torch.zeros(n_data, A, A)
tfcompose = torch.zeros(n_data, 2, 3)

savegtcur = torch.zeros(n_data, A, A)
savegt = torch.zeros(seq_length, n_data, A, A)

for i = 1, totalIter do
 	  print(i)
          imglist = {}
          objlist = {}
          tflist = {}  
          obj_inputprev = torch.zeros(n_data, A, A)

	  for j = 1,seq_length do     
	     --print('2: ' ..j)
		    for k = 1, n_data do 
			    --print('3: ' .. k)
			    --print('4: ' .. k+ (period-1)*n_data)
			    worldnum = trainworldlist[i][1][1]
			    framenum = trainframelist[i][1][1]
			    totaltf =trainrelative[i]

			    imgname = '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' .. worldnum .. '/camera_wd/camera_' .. (framenum + j -1) .. '.jpg'
			    img = image.load(imgname)
			    img = image.scale(img, A,A)
			    img_input[{{k},{}, {}, {}}] = img
			    
			    objname = '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' .. worldnum .. '/map_global/map_' .. (framenum) .. '_' .. (j) .. '.jpg'
			    img = image.load(objname)
			    img = image.scale(img, A,A)
			    savegtcur[{{k},{}, {}}] = img

			    tfcompose[{{k},{}, {}}] = totaltf[{{},{  (3*(j-1)+1),(3*(j-1)+3) }}]
                           
		    end

		    --print(tfcompose[{{1},{}, {}}])
                    x = img_input:cuda()
	    	    x3dprev = obj_inputprev:cuda()
	    	    tfprev = tfcompose:cuda()

	    	    output = encoder:forward( {{x3dprev,tfprev}, x})
	    	    output = output:double()
                    obj_inputprev = output
                    outputsum[{{j},{}, {}, {}}]  = output
                     
                    savegt[{{j},{}, {}, {}}]  = savegtcur
	    --table.insert(imglist, img_input)
            --table.insert(objlist, obj_input)
            --table.insert(tflist, tfcompose)

	  end

        print('get inputs from forward')


    ------------------- forward pass -------------------
    

        savefile = '/media/mengmi/TOSHIBA EXT/3DGAN/IROSresults/TBworld5/predicted_ucb20e_' .. i .. '.mat'
        matio.save(savefile,outputsum)

        savefile = '/media/mengmi/TOSHIBA EXT/3DGAN/IROSresults/TBworld5/predicted_ucb20gt_' .. i .. '.mat'
        matio.save(savefile,savegt)
    
	--WriteGif('../results/gif/predicted_ucb7_' .. i ..'.gif', xmovie)


end



