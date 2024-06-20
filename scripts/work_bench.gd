extends Area2D

func highlight(toggle : bool):
	pass

func place(object):
	if $Object.get_child_count() == 0:
		object.get_parent().remove_child(object) 
		$Object.add_child(object)
