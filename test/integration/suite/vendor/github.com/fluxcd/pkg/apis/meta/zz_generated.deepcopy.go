//go:build !ignore_autogenerated

/*
Copyright 2024 The Flux authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Code generated by controller-gen. DO NOT EDIT.

package meta

import ()

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *ForceRequestStatus) DeepCopyInto(out *ForceRequestStatus) {
	*out = *in
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new ForceRequestStatus.
func (in *ForceRequestStatus) DeepCopy() *ForceRequestStatus {
	if in == nil {
		return nil
	}
	out := new(ForceRequestStatus)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *KubeConfigReference) DeepCopyInto(out *KubeConfigReference) {
	*out = *in
	if in.ConfigMapRef != nil {
		in, out := &in.ConfigMapRef, &out.ConfigMapRef
		*out = new(LocalObjectReference)
		**out = **in
	}
	if in.SecretRef != nil {
		in, out := &in.SecretRef, &out.SecretRef
		*out = new(SecretKeyReference)
		**out = **in
	}
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new KubeConfigReference.
func (in *KubeConfigReference) DeepCopy() *KubeConfigReference {
	if in == nil {
		return nil
	}
	out := new(KubeConfigReference)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *LocalObjectReference) DeepCopyInto(out *LocalObjectReference) {
	*out = *in
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new LocalObjectReference.
func (in *LocalObjectReference) DeepCopy() *LocalObjectReference {
	if in == nil {
		return nil
	}
	out := new(LocalObjectReference)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *NamespacedObjectKindReference) DeepCopyInto(out *NamespacedObjectKindReference) {
	*out = *in
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new NamespacedObjectKindReference.
func (in *NamespacedObjectKindReference) DeepCopy() *NamespacedObjectKindReference {
	if in == nil {
		return nil
	}
	out := new(NamespacedObjectKindReference)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *NamespacedObjectReference) DeepCopyInto(out *NamespacedObjectReference) {
	*out = *in
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new NamespacedObjectReference.
func (in *NamespacedObjectReference) DeepCopy() *NamespacedObjectReference {
	if in == nil {
		return nil
	}
	out := new(NamespacedObjectReference)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *ReconcileRequestStatus) DeepCopyInto(out *ReconcileRequestStatus) {
	*out = *in
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new ReconcileRequestStatus.
func (in *ReconcileRequestStatus) DeepCopy() *ReconcileRequestStatus {
	if in == nil {
		return nil
	}
	out := new(ReconcileRequestStatus)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *SecretKeyReference) DeepCopyInto(out *SecretKeyReference) {
	*out = *in
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new SecretKeyReference.
func (in *SecretKeyReference) DeepCopy() *SecretKeyReference {
	if in == nil {
		return nil
	}
	out := new(SecretKeyReference)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *ValuesReference) DeepCopyInto(out *ValuesReference) {
	*out = *in
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new ValuesReference.
func (in *ValuesReference) DeepCopy() *ValuesReference {
	if in == nil {
		return nil
	}
	out := new(ValuesReference)
	in.DeepCopyInto(out)
	return out
}
