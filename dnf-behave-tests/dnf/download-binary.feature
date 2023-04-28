@dnf5
Feature: dnf download command test for binary downloads


Background:
  Given I use repository "dnf-ci-fedora" as http
    And I set working directory to "{context.dnf.tempdir}"


# TODO(jkolarik): Do we want to return an error on non-existing input?
@not.with_dnf=5
Scenario: Download an RPM that doesn't exist
   When I execute dnf with args "download does-not-exist"
   Then the exit code is 1
    And stderr contains "No package does-not-exist available"


Scenario: Download an existing RPM
   When I execute dnf with args "download setup"
   Then the exit code is 0
    And stdout contains "setup-0:2.12.1-1.fc29.noarch"
    And file sha256 checksums are following
        | Path                                                  | sha256                                                                                        |
        | {context.dnf.tempdir}/setup-2.12.1-1.fc29.noarch.rpm  | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |


Scenario: Download an existing RPM with dependencies
   When I execute dnf with args "download filesystem --resolve"
   Then the exit code is 0
    And stdout contains "filesystem-0:3.9-2.fc29.x86_64"
    And stdout contains "setup-0:2.12.1-1.fc29.noarch"
    And file sha256 checksums are following
        | Path                                                      | sha256                                                                                        |
        | {context.dnf.tempdir}/filesystem-3.9-2.fc29.x86_64.rpm    | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm  |
        | {context.dnf.tempdir}/setup-2.12.1-1.fc29.noarch.rpm      | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |


@bz1844925
Scenario: Error when failed to resolve dependencies
   When I execute dnf with args "download filesystem --resolve --exclude setup"
   Then the exit code is 1
    And stderr is
        """
        Failed to resolve the transaction:
        Problem: package filesystem-3.9-2.fc29.x86_64 requires setup, but none of the providers can be installed
          - conflicting requests
          - package setup-2.12.1-1.fc29.noarch is filtered out by exclude filtering
        """


Scenario: Download an existing RPM with dependencies into a --destdir
   When I execute dnf with args "download filesystem --resolve --destdir={context.dnf.tempdir}/downloaddir"
   Then the exit code is 0
    And stdout contains "filesystem-0:3.9-2.fc29.x86_64"
    And stdout contains "setup-0:2.12.1-1.fc29.noarch"
    And file sha256 checksums are following
        | Path                                                                  | sha256                                                                                        |
        | {context.dnf.tempdir}/downloaddir/filesystem-3.9-2.fc29.x86_64.rpm    | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm  |
        | {context.dnf.tempdir}/downloaddir/setup-2.12.1-1.fc29.noarch.rpm      | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |


Scenario: Download an existing RPM with dependencies into a --destdir where a dependency is installed
   When I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | setup-0:2.12.1-1.fc29.noarch          |
   When I execute dnf with args "download basesystem --resolve --destdir={context.dnf.tempdir}/downloaddir"
   Then the exit code is 0
    And stdout contains "basesystem-0:11-6.fc29.noarch"
    And stdout contains "filesystem-0:3.9-2.fc29.x86_64"
    And stdout does not contain "setup-2.12.1-1.fc29.noarch"
    And file sha256 checksums are following
        | Path                                                                  | sha256                                                                                        |
        | {context.dnf.tempdir}/downloaddir/basesystem-11-6.fc29.noarch.rpm     | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/basesystem-11-6.fc29.noarch.rpm   |
        | {context.dnf.tempdir}/downloaddir/filesystem-3.9-2.fc29.x86_64.rpm    | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm  |
        | {context.dnf.tempdir}/downloaddir/setup-2.12.1-1.fc29.noarch.rpm      | -                                                                                             |


Scenario: Download an existing RPM with dependencies into a --destdir where all packages are already installed
   When I execute dnf with args "install basesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | basesystem-0:11-6.fc29.noarch         |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |
   When I execute dnf with args "download basesystem --resolve --destdir={context.dnf.tempdir}/downloaddir"
   Then the exit code is 0
    And stdout contains "basesystem-0:11-6.fc29.noarch"
    And stdout does not contain "filesystem-0:3.9-2.fc29.x86_64"
    And stdout does not contain "setup-0:2.12.1-1.fc29.noarch"
    And file sha256 checksums are following
        | Path                                                                  | sha256                                                                                        |
        | {context.dnf.tempdir}/downloaddir/basesystem-11-6.fc29.noarch.rpm     | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/basesystem-11-6.fc29.noarch.rpm   |
        | {context.dnf.tempdir}/downloaddir/filesystem-3.9-2.fc29.x86_64.rpm    | -                                                                                             |
        | {context.dnf.tempdir}/downloaddir/setup-2.12.1-1.fc29.noarch.rpm      | -                                                                                             |


@bz1612874
Scenario: Download an existing RPM when there are multiple packages of the same NEVRA
  Given I use repository "dnf-ci-gpg" as http
   When I execute dnf with args "download --destdir={context.dnf.installroot}/downloaddir setup filesystem wget"
   Then the exit code is 0
    And stdout contains "setup-0:2.12.1-1.fc29.noarch"
    And stdout contains "filesystem-0:3.9-2.fc29.x86_64"
    And stdout contains "wget-0:1.19.5-5.fc29.x86_64"
      # check that each file was being downloaded only once
    And stdout does not contain "setup-0:2.12.1-1.fc29.noarch.*setup-0:2.12.1-1.fc29.noarch"
    And stdout does not contain "filesystem-0:3.9-2.fc29.x86_64.*filesystem-0:3.9-2.fc29.x86_64"
    And stdout does not contain "wget-0:1.19.5-5.fc29.x86_64.*wget-0:1.19.5-5.fc29.x86_64"
      # check that the files have been downloaded
    And file "downloaddir/setup-2.12.1-1.fc29.noarch.rpm" exists
    And file "downloaddir/filesystem-3.9-2.fc29.x86_64.rpm" exists
    And file "downloaddir/wget-1.19.5-5.fc29.x86_64.rpm" exists
