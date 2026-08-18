Checkpoint Q1.
The control plane is basically the brain of the cluster. It makes the decisions.
 It's got the API server, etcd, the scheduler, and the controller manager.
 Worker nodes are where the actual work happens. That's where your pods run. Each
 worker node has a kubelet and kube-proxy on it, plus the container runtime. So control
 plane = decides what should happen. Worker node = actually runs it.

Checkpoint Q2.
Yeah, the IP changed. Makes sense though, since pods are ephemeral. When you delete a pod,
 it's just gone. Recreating it from the same YAML doesn't bring back the old pod, it makes
 a brand new one. New pod = new IP, every time. That's the whole point of calling them
 "ephemeral" — you can't rely on a pod's IP staying the same.

Checkpoint Q3.
So here's what happened step by step:

1. Desired state was "3 replicas running."
2. I deleted one pod, so now actual state was only 2.
3. The controller noticed the gap between desired (3) and actual (2).
4. It reconciled by spinning up a new pod to get back to 3.
   Basically Kubernetes just kept checking and fixed the difference on its ow
   n. Didn't have to do anything.

Checkpoint Q4.
Because each tier is its own separate Deployment. Frontend, API, cache, database — they're all
 independent. Scaling frontend just changes the replica count for that one Deployment. It doesn't
 touch the others at all. That's the whole point of splitting things into tiers, you can scale each one on its own.

Checkpoint Q5.
Port-forward is more like a temporary tunnel straight to one specific pod, just for me, just for
 testing. If that pod dies, the tunnel's dead too. A Service is different — it sits in front of
 all the pods and load balances between them. It doesn't care which pod IP is behind it right now.
 That's why Services matter, since pod IPs keep changing when they get replaced, but the Service's address stays the same.

Checkpoint Q6.
With Docker Compose you don't really get proper rolling updates or rollbacks built in. If you update
 an image and it breaks, you're kind of stuck manually fixing it or restarting containers yourself.
 Kubernetes does rolling updates automatically, one pod at a time, so there's no downtime, and if
 something goes wrong I can just roll back with one command. Compose just doesn't track that history or manage it like that.

Checkpoint Q7.
Frontend and API don't hold any state, so it doesn't matter which pod handles a request or what its
 name is. They're interchangeable, that's why Deployment works fine. Database is different, it's stateful.
 It needs stable storage and a stable identity (like postgres-0), so a StatefulSet makes sense there — it
 keeps the naming consistent and links it to its own persistent storage instead of just handing out random pods.


Checkpoint Q8.
No, it wouldn't have survived. Without a PVC, the data just lives inside the pod's own filesystem.
 Once the pod gets deleted, that storage goes with it. A new pod would start totally fresh with no data.
 The PVC is what keeps the data around separately from the pod's lifecycle, that's the whole reason
 it survived when I deleted postgres-0.

Checkpoint Q9.
The status I got wasn't Running, Pending, CrashLoopBackOff, or OOMKilled exactly — it was more like
 ImagePullBackOff / ErrImagePull. It's not officially one of the four main ones from the lecture table,
 but it's related to Pending, just more specific. Basically it means Kubernetes tried to pull the image
 but couldn't find it (because of the fake tag), so it just keeps retrying and backing off instead of crashing the whole thing.

