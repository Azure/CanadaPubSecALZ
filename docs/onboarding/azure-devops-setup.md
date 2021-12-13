# Azure DevOps Setup Guide

## Introduction

This document provides guidance on considerations and recommended practices when creating and configuring your Azure DevOps Services environment. Keep in mind that there is no _one size fits all_ approach for determining the number of Azure DevOps Services organizations, projects, and teams. Use the information presented here in the context of your organization structure, policies, and processes.

If you already have one or more Azure DevOps Services organizations, reviewing this information may help you identify ways to improve upon your existing configuration.

## Structure considerations

This section introduces some terminology, and examines logical boundaries at the organizational level in relation to the boundaries available for separating work efforts within Azure DevOps Services.

- **Organization boundaries**

  - **`Division`**: a division is a logical grouping, at a higher level in an organization that consists of multiple `Groups`. A division may have its own dedicated Azure DevOps organization or have its own Azure DevOps project, depending on the overall organization size and number of end-state `Organizations` and `Projects`.
  - **`Group`**: a group is an area within a `Division` that typically is responsible for multiple/many `Solutions`. A group may have its own dedicated `Project` or for smaller organizations share a `Project` with other `Groups` based on a consistent `Team` naming convention within the `Project`.
  - **`Solution`**: a solution refers to a business solution that is possibly comprised of multiple components. Often, individuals will work on multiple solution efforts. At this level, `Solutions` are usually best implemented as `Teams` within a `Project`.

- **Azure DevOps boundaries**

  - **`Organization`**: an Azure DevOps organization may have the same or different Azure AD tenant backing user authentication. Generally speaking, there little to no visibility between `Projects` (and `Teams`) that are located in different Azure DevOps organizations. Furthermore, it is difficult to track work efforts (e.g. using Agile Portfolio Management techniques) for `Projects` and `Teams` that are located in different Azure DevOps organizations. Where these boundaries are desirable, perhaps at higher levels in a large organization, having a separate Azure DevOps organization may be desirable.
  - **`Project`**: a project within an Azure DevOps organization shares `Organization`-level administrative capabilities, such as work item process customization, access to the same set of extensions, a common billing source (Azure subscription), a common Azure AD tenant for identity/authentication, auditing, and a common set of security policies. Additionally, there is visibility between projects on elements such as work items, repositories.
  - **`Team`**: a team within an Azure DevOps project shares `Project`-level administrative capabilities, but may customize many aspects of the interface to their teams requirements, for example: boards, repositories, wikis, etc. Pipelines do not have team-specific views, however it is possible to have multiple Git repositories per `Project` and organize them in a folder hierarchy by `Team`. Read more about this topic in [When to add a team or project](https://docs.microsoft.com/azure/devops/pipelines/create-first-pipeline) and [When to add another project](https://docs.microsoft.com/azure/devops/organizations/projects/about-projects#when-to-add-another-project).

Generally, it is recommended to strive for fewer Azure DevOps organizations and projects where possible. For ideas on how to determine the right mix of `Organizations`, `Projects` and `Teams` for your business, refer to the Q&A in the next section.

## Create a new team, project, or organization?

Review the following questions and answers to help determine when it's most appropriate to create a new `Team` vs `Project` vs `Organization` in Azure DevOps.

| # | Question | Answer
| :-: | -------------------- | --------------------
| 1 | Is there a need for strict separation of all DevOps related material (e.g. for security reasons) between a `Group` or `Solution` and any existing Azure DevOps organizations or projects? | If `yes` then create a new Azure DevOps `Organization`, `Project`, and `Team` for this solution area.
| 2 | Is there a need for either: 1) performing user authentication against a different Azure AD tenant, and/or 2) using a separate Azure subscription to provide billing capabilities for user-licensing? | If `yes` then create a new Azure DevOps `Organization`, `Project`, and `Team` for this solution area. Note that for billing, it is possible to report on costs in Azure Cost Management by Azure DevOps `Organization` and `Project`, so you may not need to create a separate Azure DevOps `Organization` if the only billing requirement is to track expenditures.
| 3 | Does the `Group` responsible for the solution have other solutions in Azure DevOps? | If `yes` then use the existing project and create a new `Team` specifically for this solution.
| 4 | Does the `Group` require a different process template (i.e. Agile, Scrum, CMMI, Basic) than is available in any existing `Project` in their (or related) area? | If `yes` then create a new Azure DevOps `Project` with the required process template.
| 5 | Does the `Group` have very different policy/security requirements on pipelines and/or repositories from other `Groups` in any existing `Project` where they might otherwise colocate (e.g. pull request for check-ins on main branch? | If `yes` consider creating a new Azure DevOps `Project` (and `Team`) for them. Carefully consider this option and speak with the requestor in advance of doing this as it can result in inconsistent controls across projects.

## Azure AD tenant configuration

These activities should be completed once per Azure Active Directory tenant that is associated with one or more Azure DevOps organizations in your environment.

| # | | Task
| :-: | - | --------------------
| 1 | [Link](https://docs.microsoft.com/azure/devops/organizations/accounts/azure-ad-tenant-policy-restrict-org-creation#prerequisites) | Enable the Azure AD prerequisites for the `Restrict organization creation` policy.
| 2 | | Add users to the Azure AD group `Azure DevOps Administrators` who should have the ability to create new Azure DevOps organizations that are linked to your Azure AD tenant.

## Creating an Azure DevOps organization

These activities should be completed once per new Azure DevOps organization created in your environment.

| # | | Task
| :-: | - | --------------------
| 1 | [Link](https://docs.microsoft.com/azure/devops/organizations/accounts/create-organization) | Create a new Azure DevOps organization. Ensure you are signed in with the identity from the Azure AD tenant you want associated with the new Azure DevOps organization. During the creation process, ensure you select the Canada geography for [data location](https://docs.microsoft.com/azure/devops/organizations/security/data-location) - it should default to this setting based on nearest geography, but it's good to be aware of this configuration option just in case.
| 2 | [Link](https://docs.microsoft.com/azure/devops/organizations/security/set-project-collection-level-permissions) | Add one or more secondary users to the `Project Collection Administrators` group. This ensures continuity in the event the original creator (Owner) of the Azure DevOps organization is unavailable. Limit the total number of users assigned this role to the minium needed.
| 3 | [Link](https://docs.microsoft.com/azure/devops/organizations/accounts/azure-ad-tenant-policy-restrict-org-creation#turn-on-the-policy) | Turn on the `Restrict organization creation` policy.
| 4 | [Link](https://docs.microsoft.com/azure/devops/organizations/billing/set-up-billing-for-your-organization-vs) | Set up billing for your organization. This step associates your Azure DevOps organization with an Azure subscription as a means of payment for things like additional `Basic` access licensed users, additional parallel jobs for Azure Pipelines, and additional storage for Azure Artifacts.
| 5 | [Link](https://docs.microsoft.com/azure/devops/organizations/accounts/add-organization-users) | Add users who will need access to projects within this organization. As part of adding users you will specify an Access Level (Stakeholder, Basic, or Visual Studio Subscriber). Optionally, you may want to consider implementing one or more [Group Rules](https://docs.microsoft.com/azure/devops/organizations/accounts/assign-access-levels-by-group-membership) to automate Access Level and Project permission assignments based on user membership in either an Azure AD group or an Azure DevOps Services group.
| 6 | [Link](https://docs.microsoft.com/azure/devops/organizations/settings/work/manage-process#set-the-default-process) | Set/change the default process to one of the following values, based on your organization's process template standard or the process you anticipate will be most often used during Azure DevOps project creation: `Agile`, `Scrum`, `Basic`, or `CMMI`. You may also customize an existing process (inheritance) and  set that to be the default process selected during Azure DevOps project creation.
| 7 | [Link](https://aka.ms/vsts-anon-access) | Turn off the option allowing public projects.
| 8 | [Link](https://docs.microsoft.com/azure/devops/organizations/settings/timezone-settings-usage) | Configure time zone settings.

## Creating an Azure DevOps project

These activities should be completed once per new Azure DevOps project created in your environment. Creating a new project can be done by members of the `Project Collection Administrators` role at the Azure DevOps organization level. The other activities in this section can be performed by either a member of the `Project Collection Administrators` role, or by any individual added to the `Project Administrators` role for the newly created project.

| # | | Task
| :-: | - | --------------------
| 1 | [Link](https://docs.microsoft.com/azure/devops/organizations/projects/create-project) | Create a new Azure DevOps project. You will need to have the following information available to configure the newly created project: project name, visibility (typically Private), version control (typically Git), and work item process (e.g. Agile, Scrum, Basic, or CMMI). You should develop and follow an standard naming convention for projects. This allows users to easily find and identify projects based on their usage within the organization. While you may use spaces in your project names, this is discouraged as it leads to special encoding requirements in reference URLs. E.g. the URL-encoded sequence for a space character is `%20`, which has the effect of visually cluttering URL references to elements of the project, such as pipelines, and generally makes it more difficult to write automation scripts.
| 2 | [Link](https://docs.microsoft.com/azure/devops/organizations/security/add-users-team-project) | Add users to the newly created project. When adding users to a project, you will place them into one of three roles: 1) Readers, 2) Contributors, or 3) Project Administrators. The list of users and their roles should be acquired from the group requesting the project as part of the intake process. Once one or more Project Administrators have been added to a project, they can complete any additional configuration for the project (e.g. the following steps in this list), or you may continue and do so on their behalf.
| 3 | [Link](https://docs.microsoft.com/azure/devops/organizations/settings/set-services) | **Optionally** disable visibility of any Azure DevOps services that are not required by the project members. For example, if no project members are using source control (Azure Repos), you can turn off its visibility in the menu at the project scope so it does not appear in the sidebar menu.
| 4 | [Link](https://docs.microsoft.com/azure/devops/organizations/projects/create-project#add-a-repository-to-your-project) | Add a repository to the project. Additionally you may also: [Clone an existing Git repo](https://docs.microsoft.com/azure/devops/repos/git/clone), [Import a Git repo](https://docs.microsoft.com/azure/devops/repos/git/import-git-repository), and [Import a repo from TFVC](https://docs.microsoft.com/azure/devops/repos/git/import-from-tfvc).
| 5 | [Link](https://docs.microsoft.com/azure/devops/boards/work-items/view-add-work-items) | Add new work items to the project. For example, populate an initial set of User Stories.
| 6 | [Link](https://docs.microsoft.com/azure/devops/organizations/settings/about-areas-iterations) | Configure `Area` and `Iteration` (sprint) paths.

## Creating an Azure DevOps team in existing project

These activities should be completed once per new `Team` created in an existing Azure DevOps project. They can be (and usually are) performed by a member of the `Project Administrators` role in the current project where the team will be created. They can also be performed optionally by any member of the `Project Collection Administrators` role at the Azure DevOps organization level.

| # | | Task
| :-: | - | --------------------
| 1 | [Link](https://docs.microsoft.com/azure/devops/organizations/settings/add-teams) | Add a new team.
| 2 | [Link](https://docs.microsoft.com/azure/devops/organizations/settings/add-team-administrator) | Add one or more team administrators.
| 3 | [Link](https://docs.microsoft.com/en-us/azure/devops/organizations/security/add-users-team-project) | Add users to the team.
| 4 | [Link](https://docs.microsoft.com/azure/devops/project/navigation/set-favorites) | Set team favorites.
| 5 | [Link](https://docs.microsoft.com/azure/devops/boards/plans/portfolio-management) | Determine if this team is part of a larger portfolio management effort, and if so follow the guidance in [Configure a hierarchy of team](https://docs.microsoft.com/azure/devops/boards/plans/configure-hierarchical-teams) to ensure the newly created team is configured in the hierarchy.
