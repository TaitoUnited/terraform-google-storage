# Google Cloud storage

Example usage:

```
provider "google" {
  project = "my-infrastructure"
  region  = "europe-west1"
  zone    = "europe-west1b"
}

resource "google_project_service" "compute" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

module "storage" {
  source          = "TaitoUnited/storage/google"
  version         = "1.0.0"
  providers       = [ google ]
  depends_on      = [ google_project_service.compute ]

  storage_buckets = yamldecode(file("${path.root}/../infra.yaml"))["storageBuckets"]
}
```

Example YAML:

```
storageBuckets:
  - name: zone1-state
    purpose: state
    location: europe-west1
    storageClass: REGIONAL
    versioningEnabled: true
    versioningRetainDays: 90
  - name: zone1-projects
    purpose: projects
    location: europe-west1
    storageClass: REGIONAL
    versioningEnabled: true
    versioningRetainDays: 90
  - name: zone1-public
    purpose: public
    location: europe-west1
    storageClass: REGIONAL
    versioningEnabled: true
    versioningRetainDays: 90
    cors:
      - origin: ["*"]
    cdnDomain: cdn.mydomain.com
    cloudbuildDeployEnabled: true
  - name: zone1-temp
    purpose: temporary
    location: europe-west1
    storageClass: REGIONAL
    versioningEnabled: false
    autoDeletionRetainDays: 90
  - name: zone1-archive
    purpose: archive
    location: europe-west1
    storageClass: REGIONAL
    versioningEnabled: true
    transitionRetainDays: 90
    transitionStorageClass: ARCHIVE
```

Combine with the following modules to get a complete infrastructure defined by YAML:

- [Admin](https://registry.terraform.io/modules/TaitoUnited/admin/google)
- [DNS](https://registry.terraform.io/modules/TaitoUnited/dns/google)
- [Network](https://registry.terraform.io/modules/TaitoUnited/network/google)
- [Kubernetes](https://registry.terraform.io/modules/TaitoUnited/kubernetes/google)
- [Databases](https://registry.terraform.io/modules/TaitoUnited/databases/google)
- [Storage](https://registry.terraform.io/modules/TaitoUnited/storage/google)
- [Monitoring](https://registry.terraform.io/modules/TaitoUnited/monitoring/google)
- [PostgreSQL privileges](https://registry.terraform.io/modules/TaitoUnited/postgresql-privileges/google)
- [MySQL privileges](https://registry.terraform.io/modules/TaitoUnited/mysql-privileges/google)

TIP: Similar modules are also available for AWS, Azure, and DigitalOcean. All modules are used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/).

See also [Google Cloud project resources](https://registry.terraform.io/modules/TaitoUnited/project-resources/google), [Full Stack Helm Chart](https://github.com/TaitoUnited/taito-charts/blob/master/full-stack), and [full-stack-template](https://github.com/TaitoUnited/full-stack-template).

Contributions are welcome!