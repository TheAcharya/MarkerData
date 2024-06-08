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
                icon: "music.note",
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
                icon: "square.and.arrow.up",
                title: "Share Destination",
                description: "Install Marker Data’s Share Destination. Marker Data will proceed to install its Extension into Final Cut Pro."
            ),
            .init(
                icon: "server.rack",
                title: "Database Templates",
                description: "It is strongly recommended to duplicate the provided Marker Data Template if you intend to use Notion or Airtable."
            ),
            .init(
                icon: "book",
                title: "Documentation",
                description: "Enhance your understanding of Marker Data by thoroughly reading the provided documentation available through the Help menu."
            )
        ]
    ),
    .init(
        title: "Initial Steps",
        features: [
            .init(
                icon: "square.and.arrow.up",
                title: "Your First Configuration",
                description: "You are required to create a new Configuration in order to utilise the complete functionality of Marker Data."
            ),
            .init(
                icon: "server.rack",
                title: "Select Your Export Folder",
                description: "You can select your desired location by clicking on the Folder Icon under General."
            ),
            .init(
                icon: "book",
                title: "Update Active Configuration",
                description: "Press ⌘+S on your keyboard to save your Active Configuration."
            )
        ]
    ),
]
