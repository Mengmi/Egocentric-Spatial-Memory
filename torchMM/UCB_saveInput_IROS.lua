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
seq_length = 32 --number of fixations
n_channel = 3 -- channels of nautral images RGB
A = 32 -- width/height of image
n_data = 10 -- batch size
------------------------------------------------------------------------------------

print('start program')



--train
print('Model setup complete')

trainworldlist = torch.load('../datalist/IROStrainworldlist')
trainrelative = torch.load('../datalist/IROStrainrelative')
trainframelist = torch.load('../datalist/IROStrainframelist')
trainposeindex = torch.load('../datalist/IROStrainposeindex')

--peiriod divided by 2000
--1313, 2957, 4952,6951,8951,10954,12953
for i = 11900, 12000 do --#trainworldlist do
 
  print('now: ' .. i)
  period = i%(#trainworldlist) + 1
  --print('1: ' .. period)
  if period <= (#trainworldlist-n_data+1) then


          local img_input = torch.zeros(seq_length, n_data, n_channel, A, A)
	  local obj_input = torch.zeros(seq_length, n_data, A, A)
	  local obj_input_local = torch.zeros(seq_length, n_data, A, A)
	  local tfcompose = torch.zeros(seq_length, n_data, 2, 3)
	  local actlist = torch.zeros(seq_length, n_data)
          for j = 1,seq_length do     
	     --print('2: ' ..j)
	    for k = 1, n_data do 
		    --print('3: ' .. k)
		    --print('4: ' .. k+ (period-1)*n_data)
		    worldnum = trainworldlist[k+ period-1][1][1]
		    framenum = trainframelist[k+ period-1][1][1]
		    --totaltf =trainrelative[k+ period-1]

                    
		    imgname = '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' .. worldnum .. '/camera_wd/camera_' .. (framenum + j -1) .. '.jpg'
--print('world' .. worldnum .. ' framenum: ' .. framenum)
		                        
--print(imgname)
		    img = image.load(imgname)
		    img = image.scale(img, A,A)
		    img_input[{{j},{k},{}, {}, {}}] = img
		    --print('load camera image')

		    --[[objname = '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/World' .. worldnum .. '/map_global/map_' .. (framenum) .. '_' .. j .. '.jpg'
		    img = image.load(objname)
		    img = image.scale(img, A,A)
		    obj_input[{{j},{k},{}, {}}] = img]]--


                    objname = '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' .. worldnum .. '/map_global_local/map_' .. (framenum) .. '_' .. j .. '.jpg'
		    img = image.load(objname)
		    img = image.scale(img, A,A)
		    obj_input_local[{{j},{k},{}, {}}] = img
                    --print('world' .. worldnum .. ' framenum: ' .. framenum)
		    --print(objname)
                    --print('load map image')


		    --tfcompose[{{j},{k},{}, {}}] = totaltf[{{},{  (3*(j-1)+1),(3*(j-1)+3) }}]

                    --totalac  = trainposeindex[k+ period-1]
                    --actlist[j][k] = totalac[1][j]
	    end

	    
	  end

	  torch.save( '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/All_IROS/all_img_input_'.. period .. '.t7', img_input)
          --torch.save( '/data/mengmi/3dDatabase/Nav3D/All/all_obj_input_'.. period .. '.t7', obj_input)
          torch.save( '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/All_IROS/all_obj_local_input_'.. period .. '.t7', obj_input_local)
          --torch.save( '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/All/all_tfcompose_'.. period .. '.t7', tfcompose)
	  --torch.save( '/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/All/all_actlist_'.. period .. '.t7', actlist)
  end

  

  collectgarbage()
end


print('Sucessfully generated! Bye!')
os.exit()
