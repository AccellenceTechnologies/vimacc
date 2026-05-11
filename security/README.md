# vimacc Software Bill of Materials (SBOM)

This directory contains published Software Bills of Materials (SBOMs)
for vimacc release artifacts and runtime environments.

The SBOMs are provided in CycloneDX JSON format (`*.cdx.json`)
to support:

- Software supply chain transparency
- Vulnerability management
- Compliance processes
- Security assessments
- Dependency tracking

## Directory Structure

### `latest/`

Contains the most recently published SBOMs for the current release.

Example:

- `vimacc-enterprise.cdx.json`
- `vimacc-docker-runtime.cdx.json`

### `releases/<version>/`

Contains immutable SBOM snapshots for specific product releases.

Example:

```text
releases/2.2.15.20/
```

## Integrity Verification

The `checksums.sha256` files contain SHA-256 hashes for integrity verification.

Example:

```bash
sha256sum -c checksums.sha256
```

## Format

SBOMs are generated in CycloneDX JSON format.

More information:

- https://cyclonedx.org/
- https://github.com/CycloneDX/specification

## Property Taxonomies

The published SBOMs may contain additional metadata properties
based on custom CycloneDX property taxonomies.

### Accellence CycloneDX Property Taxonomy

vimacc SBOMs may include properties defined by the
Accellence CycloneDX Property Taxonomy:

- https://github.com/AccellenceTechnologies/cyclonedx-property-taxonomy

These extensions are used to provide additional product,
deployment, lifecycle and security-related metadata.

### BSI TR-03183 CycloneDX Property Taxonomy

vimacc SBOMs may additionally include properties defined by the
BSI TR-03183 CycloneDX Property Taxonomy:

- https://github.com/BSI-Bund/tr-03183-cyclonedx-property-taxonomy

These properties are intended to support structured security
and compliance information in alignment with the German
Federal Office for Information Security (BSI) guidance.

## Notes

The published SBOMs represent the packaged release artifacts
at the time of release generation.