class_name NumberIndicator
extends Label

## NumberIndicator class
##
## This contains code used by the NumberIndicator ui scene that handles a simple label text that shows simple stats like Stregth or Level.

## Refreshes the value of the NUmberIndicator
## current_value: The value of the property (level for example)
## max_value: The max value of the property (optional)
## optional_prefix: A text prefix (optional) (trailing space is not included)
## optional_suffix: A text prefix (optional) (trailing space is not included)
func refresh(current_value: int, max_value: int = -1, optional_prefix: String = "", optional_suffix: String = "") -> void:	
	## Set the text
	var is_max_value : bool = false
	var is_optional_prefix: bool = false
	var is_optional_suffix: bool = false
	
	if max_value != -1:
		is_max_value = true
	
	if optional_prefix != "":
		is_optional_prefix = true
		
	if optional_suffix != "":
		is_optional_suffix = true
		
	if is_max_value and is_optional_prefix and is_optional_suffix:
		text = optional_prefix + str(current_value) + "/" + str(max_value) + optional_suffix
	elif is_max_value and not is_optional_prefix and not is_optional_suffix:
		text = str(current_value) + "/" + str(max_value)
	elif is_max_value and is_optional_prefix and not is_optional_suffix:
		text = optional_prefix + str(current_value) + "/" + str(max_value)
	elif is_max_value and not is_optional_prefix and is_optional_suffix:
		text = str(current_value) + "/" + str(max_value) + optional_suffix
	elif not is_max_value and is_optional_prefix and is_optional_suffix:
		text = optional_prefix + str(current_value) + optional_suffix
	elif not is_max_value and not is_optional_prefix and is_optional_suffix:
		text = str(current_value) + optional_suffix
	elif not is_max_value and is_optional_prefix and not is_optional_suffix:
		text = optional_prefix + str(current_value)
	elif not is_max_value and not is_optional_prefix and not is_optional_suffix:
		text = str(current_value)
