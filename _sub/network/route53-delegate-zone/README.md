# Route 53 activate dns zone module
This module can be used to active an already created sub dns zone in route 53.
If a sub domain zone is created in route 53 the parent dns needs to point at the nameservers for the sub domain.

This module requires a parent's zone id in route 53, the domain name of the sub dns and the assigned nameservers for the sub.
All of the variables, except for the parent's zone id, will be outputted from the route53-zone module.