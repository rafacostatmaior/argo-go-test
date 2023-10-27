resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "3.35.4"

  values = [file("values/argocd.yaml")]
}

resource "kubectl_manifest" "argo_project" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: devops
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  description: "kube services"
  sourceRepos:
    - '*'
  destinations:
    - namespace: "*"
      server: https://kubernetes.default.svc
      name: in-cluster
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceBlacklist:
    - group: ''
      kind: ResourceQuota
    - group: ''
      kind: LimitRange
    - group: ''
      kind: NetworkPolicy
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
  orphanedResources:
    warn: false
YAML

  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "argo_apps" {
  yaml_body  = <<YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: app-of-apps
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      destination:
        namespace: app-of-apps
        server: "https://kubernetes.default.svc"
      source:
        path: "argo-cd"
        repoURL: "https://github.com/rafacostatmaior/argo-go-test"
        targetRevision: "HEAD"
      project: "devops"
      syncPolicy:
        managedNamespaceMetadata:
          labels:
            managed: "argo-cd"
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
          - PruneLast=true
        retry:
          limit: 5
          backoff:
            duration: 5s
            maxDuration: 3m0s
            factor: 2
YAML
  depends_on = [helm_release.argocd]
}

# resource "kubectl_manifest" "argo_secret" {
#   for_each = { for s in var.secrets : s.secret_name => s }

#   yaml_body = <<YAML
#     apiVersion: v1
#     kind: Secret
#     metadata:
#       name: ${each.value.secret_name}
#       namespace: ${var.argo_namespace}
#       labels:
#         argocd.argoproj.io/secret-type: repository
#     stringData:
#       type: ${each.value.type}
#       url: ${each.value.url}
#       sshPrivateKey: |
#         ${each.value.secret}
#       insecure: "true" # Ignore validity of server's TLS certificate. Defaults to "false"
#       enableLfs: "true" # Enable git-lfs for this repository. Defaults to "false"
# YAML

#   depends_on = [helm_release.argocd]

# }
