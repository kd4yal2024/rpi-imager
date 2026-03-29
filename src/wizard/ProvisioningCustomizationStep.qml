/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2026 Raspberry Pi Ltd
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../qmlcomponents"

import RpiImager

WizardStepBase {
    id: root

    required property ImageWriter imageWriter
    required property var wizardContainer

    title: qsTr("Provisioning")
    subtitle: qsTr("Configure optional first-boot repository provisioning")
    nextButtonText: CommonStrings.continueText
    backButtonText: CommonStrings.back
    showSkipButton: true
    readonly property string repoUrlTrimmed: repoUrlField.text.trim()
    readonly property bool repoUrlValid: !enableSwitch.checked
        || (repoUrlTrimmed.length > 0 && imageWriter.isValidProvisioningRepoUrl(repoUrlTrimmed))
    nextButtonEnabled: repoUrlValid

    readonly property string defaultBranch: "main"
    readonly property string defaultPath: "provision/cloud-init"

    function persistSetting(key, value) {
        wizardContainer.customizationSettings[key] = value
        imageWriter.setPersistedCustomisationSetting(key, value)
    }

    function removeSetting(key) {
        delete wizardContainer.customizationSettings[key]
        imageWriter.removePersistedCustomisationSetting(key)
    }

    function clearProvisioningSettings() {
        removeSetting("provisioningEnabled")
        removeSetting("provisioningRepoUrl")
        removeSetting("provisioningRepoBranch")
        removeSetting("provisioningPath")
        wizardContainer.provisioningConfigured = false
    }

    function saveProvisioningSettings() {
        var url = repoUrlField.text.trim()
        if (!enableSwitch.checked || url.length === 0) {
            clearProvisioningSettings()
            return
        }
        if (!imageWriter.isValidProvisioningRepoUrl(url)) {
            return
        }

        var branch = repoBranchField.text.trim()
        var path = repoPathField.text.trim()

        persistSetting("provisioningEnabled", true)
        persistSetting("provisioningRepoUrl", url)
        persistSetting("provisioningRepoBranch", branch.length > 0 ? branch : defaultBranch)
        persistSetting("provisioningPath", path.length > 0 ? path : defaultPath)
        wizardContainer.provisioningConfigured = true
    }

    Component.onCompleted: {
        var s = wizardContainer.customizationSettings
        enableSwitch.checked = !!s.provisioningEnabled
        repoUrlField.text = s.provisioningRepoUrl || ""
        repoBranchField.text = s.provisioningRepoBranch || defaultBranch
        repoPathField.text = s.provisioningPath || defaultPath
        wizardContainer.provisioningConfigured = enableSwitch.checked && repoUrlField.text.trim().length > 0
    }

    onNextClicked: saveProvisioningSettings()

    onSkipClicked: {
        clearProvisioningSettings()
        wizardContainer.hostnameConfigured = false
        wizardContainer.localeConfigured = false
        wizardContainer.userConfigured = false
        wizardContainer.wifiConfigured = false
        wizardContainer.sshEnabled = false
        wizardContainer.jumpToStep(wizardContainer.stepWriting)
    }

    content: [
    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Style.cardPadding
        spacing: Style.spacingMedium

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingMedium

            Switch {
                id: enableSwitch
            }

            Text {
                text: qsTr("Enable provisioning from Git repository")
                font.pixelSize: Style.fontSizeFormLabel
                font.family: Style.fontFamily
                color: Style.formLabelColor
            }
        }

        Text {
            text: qsTr("When enabled, cloud-init will clone and run your provisioning script on first boot.")
            font.pixelSize: Style.fontSizeDescription
            font.family: Style.fontFamily
            color: Style.textDescriptionColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        TextField {
            id: repoUrlField
            Layout.fillWidth: true
            enabled: enableSwitch.checked
            placeholderText: qsTr("Repository URL (required)")
            text: ""
        }

        TextField {
            id: repoBranchField
            Layout.fillWidth: true
            enabled: enableSwitch.checked
            placeholderText: qsTr("Branch (default: main)")
            text: defaultBranch
        }

        TextField {
            id: repoPathField
            Layout.fillWidth: true
            enabled: enableSwitch.checked
            placeholderText: qsTr("Path inside repo (default: provision/cloud-init)")
            text: defaultPath
        }

        Text {
            visible: enableSwitch.checked && repoUrlTrimmed.length === 0
            text: qsTr("Repository URL is required when provisioning is enabled.")
            font.pixelSize: Style.fontSizeCaption
            font.family: Style.fontFamily
            color: Style.formLabelErrorColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            visible: enableSwitch.checked && repoUrlTrimmed.length > 0 && !repoUrlValid
            text: qsTr("Use a GitHub repository URL like https://github.com/owner/repo or .../tree/branch/path.")
            font.pixelSize: Style.fontSizeCaption
            font.family: Style.fontFamily
            color: Style.formLabelErrorColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
        }
    }
    ]
}
