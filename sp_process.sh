#!/bin/bash
for d in 2022*/; do
	echo "$d"
	cd $d
	filename=*A2*.fil
	echo $filename


	src=$(echo $filename | cut -d'_' -f2)
	ant=$(echo $filename | cut -d'_' -f3)
	date=$(echo $filename | cut -d'_' -f4)
	time=$(echo $filename | cut -d'_' -f5 | cut -c1-6)


	list_sp=0 #if this variable is set to 0, then the list of SP wasn't made. If it is 1, then it was
	lodm=150
	ndm=100
	dmh=1
	nchan=64

#------------------------------------------------------
#In this part of the block I check if there is a folder that contains the dat files, this is a bit problematic
# so I should change this. The idea is that if there is a folder dat, some part of the process has been done
	if [ -d "./files_dat" ]; then
		echo "There is a files_dat folder"
        #There is a files_dat folder, now, lets check if there are .dat files inside
		#cd ./files_dat

		folder_name="."

#Here I should specify which is the last file that I expect to be created		
		ps_file_spected="psb_${ndm}dm_ldm${ldm}_dmstep${dmh}_mask_${src}_${ant}_${date}_singlepulse.ps"



		echo "The last created file in the folder is: "
		ls -1t . | head -n 1
		last_file=$(ls -1t . | head -n 1) t
        #Here, if the list of candidates was made, then the dat files were also made (this should be check)

        #Here I check if the singlepulse.ps file was created


		if ls "$folder_name"/"$ps_file_spected" 1> /dev/null 2>&1; then
			echo "There exist *singlepulse.ps, the list of candidates seems to have been done"
			$list_sp=1
            #Acá, si ya termino de hacer la lista de candidatos sale.
		else
		#Si el último archivo creado no es un .ps, entonces no se hizo la lista de candidatos
			echo "There ain't a *singlepulse.ps, the list of candidates wasn't made"

		#aca quiero chequear si se hicieron todos los archivos .dat pero falto hacer el single.pulse
			(( lastdatfile = lodm + ndm - 1))
			name_file_dat=psb_${ndm}dm_ldm${lodm}_dmstep${dmh}_mask_${src}_${ant}_${date}_DM${lastdatfile}.00.dat

			if [ -f "$name_file_dat" ]; then
				echo "The last dat file was created"
		
			else
				echo "The last dat file wasn't created"
			fi
		list_sp=0   #esta variable me va a ir indicando si se hace la lista de candidatos o no

		fi


#--------------------------------------------------------------------
# Here we start the part if there isnt a dat folder
	else

        #Acá es el punto 0 de una carpeta que no tenga ninguna carpeta ./files_dat
		echo "There ain't a folder for the dat files. I'm going to do one"

        #En el siguiente if, chequeo si hay archivos .dat afuera de la carpeta oara ellos, es simplemente una alerta
		if find . -type f -name "*.dat" -print -quit | grep -q .; then
			echo "There are .dat files in this folder, and not inside the files_dat folder. Something must have gone wrong"
		else
			echo "There aren't any .dat files. Let's make them"
			maskname=$(find . -type f -name "*.mask" | sort -r | head -n 1) #elijo la última máscara hecha
			output_name_dat="psb_${ndm}dm_ldm${lodm}_dmstep${dmh}_mask_${src}_${ant}_${date}"
			prepsubband $filename -o $output_name_dat -nsub $nchan -lodm $lodm -dmstep $dmh -numdms $ndm -mask $maskname
			mkdir ./files_dat
			mv *.dat ./files_dat
			mv *.inf ./files_dat
			echo "Finished doing the time series"
		fi


	fi
    #Termina de hacerse las series temporales dedispersadas

	if [ "$list_sp" -eq 1 ]; then
		echo "The list of candidates has been made"
	else
		echo "The list of candidates wasn't made"
        #si está adentro del docker del environment de python 2 es sin el python2 adelante
		#activar el environment

		single_pulse_search.py files_dat/*.dat -t 8
		cat files_dat/*.singlepulse > all_sp_t_8SN_${src}_${ant}_${date}.singlepulse
		filename_singlepulse=all_sp_t_8SN_${src}_${ant}_${date}.singlepulse
		mkdir files_singlepulse
		mv files_dat/*.singlepulse files_singlepulse
		mv files_dat/*.ps .
	#Muevo el archivo con todos los candidatos afuera, porque quiero chequear esa lista con SpS

		list_sp=1
		echo "We finished the search"
        #Cambio la variable a 1, así ya queda hecha
        
		echo "Let's delete the dat file DM<170 and DM>200"
		#ENtro a la carpeta de los archivos .dat
		cd ./files_dat
		rm -r psb_*DM10*
		rm -r psb_*DM11*
		rm -r psb_*DM12*
		rm -r psb_*DM13*
		rm -r psb_*DM14*
		rm -r psb_*DM15*
		rm -r psb_*DM16*
		rm -r psb_*DM19*
		rm -r psb_*DM2*
		rm -r psb_*DM3*
		rm -r psb_*DM4*
		
		echo "Borre los .dat en el directorio"
		echo $d
	
		cd ..
		#ahí ya salí de la carpeta de los .dat

	fi

        if  -f sps_without_nofilter/*.hdf5; then
                echo "There is a hdf5 file, the search has already been done"
        else
                echo "There isn't a hdf5 file. Let's search for the real candidates"
#       
                python /home/jovyan/SpS/sps/sps.py $filename_singlepulse -no_filter -no_plot -store_name sps_nofilter.hdf5
                mkdir sps_nofilter
                
                mv sps_nofilter.hdf5 ./sps_nofilter
        #Buscar con SPS los archivos, deber  amos de tener el archivo all_sp_t_8SN.singlepulse aqu   afuera, en la misma carpeta que el .fil, as $
                python /home/jovyan/SpS/sps/sps.py $filename_singlepulse -no_plot -store_name sps_without_nofilter.hdf5
                mkdir sps_without_nofilter 
                
                mv sps_without_nofilter.hdf5 ./sps_without_nofilter
        fi



	cd ..
done
