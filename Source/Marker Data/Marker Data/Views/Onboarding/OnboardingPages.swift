//
//  OnboardingPages.swift
//  Marker Data
//
//  Created by Milán Várady on 08/06/2024.
//

import Foundation

/// Onbarding pages for ``OnboardingView``
let onboardingPages: [OnboardingPageView] = [
    .init(
        title: "Features of Marker Data",
        features: [
            .init(
                icon: "puzzlepiece.extension",
                title: "Integration with Final Cut Pro",
                description: "Integrates with Final Cut Pro, boasting a native Share Destination & Workflow Extension."
            ),
            .init(
                icon: "briefcase",
                title: "Configurations",
                description: "Allows the creation of multiple configurations tailored to diverse project requirements."
            ),
            .init(
                icon: "server.rack",
                title: "Databases",
                description: "Native integration with renowned databases such as Airtable and Notion."
            )
        ]
    ),
    .init(
        title: "Features of Marker Data",
        features: [
            .init(
                icon: "photo",
                title: "Image",
                description: "Functionality allowing batch extraction and rendering of stills or animated GIFs based on each Marker's timecode."
            ),
            .init(
                icon: "tag",
                title: "Labels",
                description: "Versatile features for batch burning-in labels, embedding comprehensive metadata of each Marker onto stills or animated GIFs."
            ),
            .init(
                icon: "tablecells",
                title: "Database Templates",
                description: "It is strongly advised that to duplicate the supplied Marker Data Template."
            )
        ]
    ),
    .init(
        title: "Features of Marker Data",
        features: [
            .init(
                icon: "tablecells",
                title: "Spreadsheet Compatible",
                description: "Marker Data is capable of generating spreadsheet-compatible files, including CSV, TSV, and Excel formats, from the Marker metadata in Final Cut Pro."
            ),
            .init(
                icon: "waveform.path",
                title: "DAW Compatible",
                description: "Marker Data can generate MIDI Markers for import into any Digital Audio Workstation."
            ),
            .init(
                icon: "play.rectangle",
                title: "YouTube Chapter",
                description: "Marker Data can generate YouTube Chapter Markers directly from the timeline in Final Cut Pro."
            )
        ]
    ),
    .init(
        title: "Initial Steps",
        features: [
            .init(
                icon: "1.square",
                title: "Share Destination",
                description: "Install Marker Data’s Share Destination. Marker Data will proceed to install its Extension into Final Cut Pro."
            ),
            .init(
                icon: "2.square",
                title: "Database Templates",
                description: "It is strongly recommended to duplicate the provided Marker Data Template if you intend to use Notion or Airtable."
            ),
            .init(
                icon: "3.square",
                title: "Your First Configuration",
                description: "You are required to create a new Configuration in order to utilise the complete functionality of Marker Data."
            )
        ]
    ),
    .init(
        title: "Initial Steps",
        features: [
            .init(
                icon: "4.square",
                title: "Select Your Export Folder",
                description: "Select your desired location by clicking on the Folder Icon under General."
            ),
            .init(
                icon: "5.square",
                title: "Select Your Extraction Profile",
                description: "Select your preferred Extraction Profile. If you wish to use the Notion or Airtable profiles, it is necessary to create corresponding Database Profiles beforehand."
            ),
            .init(
                icon: "6.square",
                title: "Update Active Configuration",
                description: "Press ⌘+S on your keyboard to save your Active Configuration."
            )
        ]
    ),
    .init(
        title: "Initial Steps",
        features: [
            .init(
                icon: "7.square",
                title: "Your First Extraction",
                description: "Initiate your first extraction by selecting either Marker Data Source or Marker Data H.264 from the Share menu in Final Cut Pro."
            ),
            .init(
                icon: "8.square",
                title: "Using Workflow Extension",
                description: "If images are not required, you may simply drag and drop your timeline into the Marker Data Workflow Extension."
            ),
            .init(
                icon: "9.square",
                title: "Documentation",
                description: "Enhance your understanding of Marker Data by thoroughly reading the provided documentation available through the Help menu."
            )
        ]
    ),
]
