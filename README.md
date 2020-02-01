# Tanzu Mission Control Terraform Provider Example 

This repository contains example Terraform configuration leveraging the VMware Tanzu Mission Control Terraform Provider.

Currently behavior is:
- Provision TMC clusters in two separate AWS regions
- Initialize Helm
- Install Nginx Ingress
- Install Cert Manager
- Install Wavefront Agent
- Add Route53 entries for weighted routing between clusters

TODO:
- Install some application for OOTB demo
- Switch to Contour for ingress
- Add multi-region RDS cluster