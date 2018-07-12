;; Auto-generated. Do not edit!


(when (boundp 'local_map::SaveMap)
  (if (not (find-package "LOCAL_MAP"))
    (make-package "LOCAL_MAP"))
  (shadow 'SaveMap (find-package "LOCAL_MAP")))
(unless (find-package "LOCAL_MAP::SAVEMAP")
  (make-package "LOCAL_MAP::SAVEMAP"))
(unless (find-package "LOCAL_MAP::SAVEMAPREQUEST")
  (make-package "LOCAL_MAP::SAVEMAPREQUEST"))
(unless (find-package "LOCAL_MAP::SAVEMAPRESPONSE")
  (make-package "LOCAL_MAP::SAVEMAPRESPONSE"))

(in-package "ROS")





(defclass local_map::SaveMapRequest
  :super ros::object
  :slots (_name ))

(defmethod local_map::SaveMapRequest
  (:init
   (&key
    ((:name __name) "")
    )
   (send-super :init)
   (setq _name (string __name))
   self)
  (:name
   (&optional __name)
   (if __name (setq _name __name)) _name)
  (:serialization-length
   ()
   (+
    ;; string _name
    4 (length _name)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _name
       (write-long (length _name) s) (princ _name s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _name
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _name (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass local_map::SaveMapResponse
  :super ros::object
  :slots ())

(defmethod local_map::SaveMapResponse
  (:init
   (&key
    )
   (send-super :init)
   self)
  (:serialization-length
   ()
   (+
    0
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;;
   self)
  )

(defclass local_map::SaveMap
  :super ros::object
  :slots ())

(setf (get local_map::SaveMap :md5sum-) "c1f3d28f1b044c871e6eff2e9fc3c667")
(setf (get local_map::SaveMap :datatype-) "local_map/SaveMap")
(setf (get local_map::SaveMap :request) local_map::SaveMapRequest)
(setf (get local_map::SaveMap :response) local_map::SaveMapResponse)

(defmethod local_map::SaveMapRequest
  (:response () (instance local_map::SaveMapResponse :init)))

(setf (get local_map::SaveMapRequest :md5sum-) "c1f3d28f1b044c871e6eff2e9fc3c667")
(setf (get local_map::SaveMapRequest :datatype-) "local_map/SaveMapRequest")
(setf (get local_map::SaveMapRequest :definition-)
      "string name
---

")

(setf (get local_map::SaveMapResponse :md5sum-) "c1f3d28f1b044c871e6eff2e9fc3c667")
(setf (get local_map::SaveMapResponse :datatype-) "local_map/SaveMapResponse")
(setf (get local_map::SaveMapResponse :definition-)
      "string name
---

")



(provide :local_map/SaveMap "c1f3d28f1b044c871e6eff2e9fc3c667")


