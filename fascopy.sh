#!/usr/bin/env bash

log_id=
readonly FAILURE=1
readonly SUCCESS=0
readonly LOG_DIR_NAME='.logs'
readonly SCRIPT_NAME='fascopy'
readonly BKP_PATH=$HOME/.backup
readonly DESKTOP_PATH=$HOME/Área\ de\ Trabalho
readonly LOG_PATH="$DESKTOP_PATH"/"$LOG_DIR_NAME"/"$SCRIPT_NAME"

check_ui() {
	# Graphic User Interface - GUI
	# Command Line Interface - CLI
	[[ $TERM != 'dumb' ]] && echo 'cli' || echo 'gui'
}

display_message() {
	local readonly TIME=3
	local readonly TITLE=${SCRIPT_NAME^}

	if [ $ui = 'cli' ]; then
		echo $2
	else
		case $1 in
			'notification')
				zenity --notification --text="$2" --timeout=$TIME &;;
			'info')
				zenity --title="$TITLE" --info --text="$2" &;;
			'error')
				zenity --title="$TITLE" --error --text="$2" &;;
			*)
				exit $FAILURE
		esac
	fi
}

log() {
	local readonly INFO_LOG_NAME='info.log'
	local readonly ERROR_LOG_NAME='errors.log'
	local readonly INFO_LOG="$LOG_PATH"/"$INFO_LOG_NAME"
	local readonly ERROR_LOG="$LOG_PATH"/"$ERROR_LOG_NAME"

	if [ $((log_id++)) -eq 0 ]; then
		echo "Date: `date +\"%x\"`" > "$INFO_LOG"
		echo "Hoour: `date +\"%H h %M min\"`" >> "$INFO_LOG"
		echo '------------------------------------' >> "$INFO_LOG"

		echo "Date: `date +\"%x\"`" > "$ERROR_LOG"
		echo "Hour: `date +\"%H h %M min\"`" >> "$ERROR_LOG"
		echo '------------------------------------' >> "$ERROR_LOG"
	fi

	case $1 in
		'info')
			echo $2 >> "$INFO_LOG";;
		'error')
			echo $2 >> "$ERROR_LOG";;
		*)
			exit $FAILURE
	esac
}

checks_needed_programs() {
	# "Zenity" is the most universal dialog program, it comes pre-installed on ALMOST all distributions
	# "Zip" is the most universal compression program, it comes pre-installed on ALMOST all distributions

	message='Verifying programs...'
	display_message 'notification' "$message"

	local readonly exists
	local readonly program
	local readonly zenity_exists
	local readonly PROGRAMS=(zip)
	local readonly COMMAND_NOT_FOUND=127
	local readonly missing_programs='false'

	zenity --version > /dev/null 2> /dev/null
	zenity_exists=$?

	if [ $zenity_exists -ne 0 ]; then
		if [ $ui = 'cli' ]; then
			for program in ${PROGRAMS[@]}; do
				$program --version > /dev/null 2> /dev/null
				exists=$?

				if [ $exists -eq $COMMAND_NOT_FOUND ]; then
					missing_programs='true'

					message="The \"${program^}\" program is necessary!"
					echo "$message"

					log 'error' "$message"
				fi
			done

			if [ $missing_programs = 'true' ]; then
				exit $FAILURE
			fi
		else
			message="Attempted execution via GUI with non-existent \"Zenity\""
			log 'error' "$message"

			exit $FAILURE
		fi
	else
		missing_programs='false'

		for program in ${PROGRAMS[@]}; do
			$program --version > /dev/null 2> /dev/null
			exists=$?

			if [ $exists -eq $COMMAND_NOT_FOUND ]; then
				missing_programs='true'

				message="The \"${program^}\" program is necessary!"
				display_message 'error' "$message"

				log 'error' "$message"
			fi
		done

		if [ $missing_programs = 'true' ]; then
			exit $FAILURE
		fi
	fi
}

create_dirs() {
	local readonly BKP_DIR_NAME='.backup'

	if [ ! -e "$LOG_PATH" ]; then
		mkdir -p "$LOG_PATH"

		message="The directory \""$LOG_DIR_NAME"/"$SCRIPT_NAME"\" was created."
		display_message 'notification' "$message"

		log 'info' "$message"
	fi

	if [ ! -d "$BKP_PATH" ]; then
		mkdir "$BKP_PATH"

		message="The directory \""$BKP_DIR_NAME"\" was created."
		display_message 'notification' "$message"

		log 'info' "$message"
	fi
}

backup() {
	message='Checking changes...'
	display_message 'notification' "$message"

	local i
	local dir
	local file
	local dir_name
	local no_update
	local diference
	local file_name
	local items_total
	local number_of_items
	local readonly FILE_NAMES=(.gitconfig)
	local readonly DIR_NAMES=(.ssh .config Documentos Downloads Imagens Modelos Música laboratory Vídeos)

	for file_name in ${FILE_NAMES[@]}; do
		FILES_PATH[i]=$HOME/"$file_name"
		FILES_BKP_PATH[i++]="$BKP_PATH"/"$file_name"
	done

	i=0
	for dir_name in ${DIR_NAMES[@]}; do
		DIRS_PATH[i]=$HOME/"$dir_name"
		DIRS_BKP_PATH[i++]="$BKP_PATH"/"$dir_name"
	done

	cd $HOME

	# File backup
	i=0
	for file in ${FILES_PATH[@]}; do
		if [ -e $file ]; then
			if [ ! -e ${FILES_BKP_PATH[i]} ]; then
				message="Copying the file \"${FILE_NAMES[i]}\"..."
				display_message 'notification' "$message"

				log 'info' "$message"

				cp -rf $file $BKP_PATH
			else
				difference=`diff $file ${FILES_BKP_PATH[i]}`
				if [ -n "$difference" ]; then
					message="Updating the file \"${FILE_NAMES[i]}\"..."
					display_message 'notification' "$message"

					log 'info' "$message"

					rm -f ${FILES_BKP_PATH[i]}
					cp -rf $file $BKP_PATH
				else
					((no_update++))
				fi
			fi
		else
			if [ -e ${FILES_BKP_PATH[i]} ]; then
				message="Removing \"${FILE_NAMES[i]}\" file that does not exist in source..."
				display_message 'notification' "$message"

				log 'info' "$message"

				rm -f ${FILES_BKP_PATH[i]}
			else
				((no_update++))
			fi
		fi

		let i++ items_total++
	done

	# Directory backup
	i=0
	for dir in ${DIRS_PATH[@]}; do
		if [ ! -e $dir ]; then
			((i++))
			continue
		else
			number_of_items=`ls $dir | wc -l`
			if [ $number_of_items -gt 0 ]; then
				if [ ! -e ${DIRS_BKP_PATH[i]} ]; then
					message="Copying the directory \"${DIR_NAMES[i]}\"..."
					display_message 'notification' "$message"

					log 'info' "$message"

					cp -rf $dir ${DIRS_BKP_PATH[i]}
				else
					difference=`diff -r $dir ${DIRS_BKP_PATH[i]}`
					if [ -n "$difference" ]; then
						message="Updating the directory \"${DIR_NAMES[i]}\"..."
						display_message 'notification' "$message"

						log 'info' "$message"

						rm -rf ${DIRS_BKP_PATH[i]}
						cp -rf $dir ${DIRS_BKP_PATH[i]}
					else
						((no_update++))
					fi
				fi
			else
				if [ -e ${DIRS_BKP_PATH[i]} ]; then
					number_of_items=`ls ${DIRS_BKP_PATH[i]} | wc -l`
					if [ $number_of_items -gt 0 ]; then
						message="Removing empty directory \"${DIR_NAMES[i]}\"..."
						display_message 'notification' "$message"

						log 'info' "$message"

						rm -rf ${DIRS_BKP_PATH[i]}
					fi
				else
					((no_update++))
				fi
			fi
		fi

		let i++ items_total++
	done

	# If there are no updates, exit the program, not updating the log and the like
	if [ $no_update -eq $items_total ]; then
		message='No changes!'
		display_message 'info' "$message"

		exit $SUCCESS
	fi
}

compact() {
	message='Compressing...'
	display_message 'notification' "$message"

	local i
	local item
	local content
#	local readonly TEMP_DIR_NAME='.temp'
#	local readonly TEMP_DIR=$HOME/"$TEMP_DIR_NAME"
	local readonly COMPACTED_FILE_NAME='backup.zip'
	local readonly COMPACTED_FILE="$DESKTOP_PATH"/"$COMPACTED_FILE_NAME"

	for item in `ls -A "$BKP_PATH" | paste`; do
		content[i++]="$item"
	done

	cd "$BKP_PATH"

	# More performant compression, but bugged
#	if [ -e "$COMPACTED_FILE" ]; then
#		mkdir "$TEMP_DIR"
#		mv "$COMPACTED_FILE" "$TEMP_DIR"
#		zip -urq9 "$TEMP_DIR"/"$COMPACTED_FILE_NAME" "${content[@]}"
#		mv "$TEMP_DIR"/"$COMPACTED_FILE_NAME" "$DESKTOP_PATH"
#		rmdir "$TEMP_DIR"
#	else
#		zip -rq9 "$COMPACTED_FILE_NAME" "${content[@]}"
#		mv "$COMPACTED_FILE_NAME" "$DESKTOP_PATH"
#	fi

	zip -rq9 "$COMPACTED_FILE_NAME" "${content[@]}"
	mv "$COMPACTED_FILE_NAME" "$DESKTOP_PATH"
}

ui=`check_ui`
checks_needed_programs
create_dirs
backup
compact
message='Finished backup!'
display_message 'info' "$message"
