package terraform.util

changes_by_type := {type: changes |
	some i
	type := input.resource_changes[i].type
	changes := [change |
		some j
		input.resource_changes[j].type == type
		change := input.resource_changes[j]
	]
}

test := resources("aws_s3_bucket")

resources(resource_type) = {rs[i] |
	some path, value
	walk(input, [path, value])
	rs := tfplan_resources(path, value)
	rs[i].type == resource_type
}

tfplan_resources(path, value) = resources {
	reverse_index(path, 1) == "resources"
	reverse_index(path, 2) == "root_module"
	resources := value
}

tfplan_resources(path, value) = resources {
	reverse_index(path, 1) == "resources"
	reverse_index(path, 3) == "child_modules"
	resources := value
}

reverse_index(path, idx) = value {
	value := path[minus(count(path), idx)]
}

is_create_or_update(actions) {
	actions[_] == "create"
}

is_create_or_update(actions) {
	actions[_] == "update"
}

missing_tag(changeset, tag) {
	not changeset.change.after.tags[tag]
}

contains_resource(name) {
	some path, value
	walk(input, [path, value])
	rs := tfplan_resources(path, value)

	rs[_].type == name
}
