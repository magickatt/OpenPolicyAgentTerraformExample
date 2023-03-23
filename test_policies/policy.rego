package employee

allow = {"permission:", permit}  {
    permit
}
allow = {"reason of deny:" ,deny }  {
   count(deny) > 0
}
permit {
   is_valid_employee
   is_allowed_action_of_employee
   has_required_employee_permissions
}
is_valid_employee {
   is_valid_employee_Company   
}
is_allowed_action_of_employee {
   allowed_action_list := {"update"}
   input.action.id == allowed_action_list[_]
}
is_valid_employee_Company {
   input.subject.company == "MyTestCompany"
}
has_required_employee_permissions  { 
   permissions_intersection := { "employee.editProfile" } & {a | a :=  split(input.subject.permissions, ",")[_]}
   count(permissions_intersection) > 0
}
deny[reason] {
  not is_valid_employee
  reason := "EMPLOYEE_DO_NOT_EXISTS"
}
deny[reason]{
    not is_allowed_action_of_employee
    reason := "INVALID_ACTION"
}
deny[reason]{
    not has_required_employee_permissions
    reason := "INVALID_PERMISSIONS"
}