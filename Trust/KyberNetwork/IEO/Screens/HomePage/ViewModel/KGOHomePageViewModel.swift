// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class KGOHomePageViewModel {
  var ieoObjects: [IEOObject] = []
  fileprivate(set) var activeObjects: [IEOObject] = []
  fileprivate(set) var pastObjects: [IEOObject] = []
  fileprivate(set) var upcomingObjects: [IEOObject] = []
  fileprivate var dataSet: [[IEOObject]] = []
  fileprivate var titles: [String] = []

  init(objects: [IEOObject]) {
    self.updateObjects(objects)
  }

  func updateObjects(_ objects: [IEOObject]) {
    self.ieoObjects = objects
    self.pastObjects = objects.filter({ $0.type == .past })
    self.activeObjects = objects.filter({ $0.type == .active })
    self.upcomingObjects = objects.filter({ $0.type == .upcoming })
    self.dataSet = []
    self.titles = []
    if !self.activeObjects.isEmpty {
      self.dataSet.append(self.activeObjects)
      self.titles.append("Active KGO")
    }
    if !self.upcomingObjects.isEmpty {
      self.dataSet.append(self.upcomingObjects)
      self.titles.append("Upcoming KGO")
    }
    if !self.pastObjects.isEmpty {
      self.dataSet.append(self.pastObjects)
      self.titles.append("Past KGO")
    }
  }

  func previewTime(for object: IEOObject) -> String {
    func displayDynamicTime(for time: TimeInterval) -> String {
      let timeInt = Int(floor(time))
      let timeDay: Int = 60 * 60 * 24
      let timeHour: Int = 60 * 60
      let timeMin: Int = 60
      let day = timeInt / timeDay
      let hour = (timeInt % timeDay) / timeHour
      let min = (timeInt % timeHour) / timeMin
      let sec = timeInt % timeMin
      return "\(day)d \(hour)h \(min)m \(sec)s"
    }

    let staticDateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "dd-MMM-yyyy hh:mm"
      return formatter
    }()
    switch object.type {
    case .past:
      return "End at: \(staticDateFormatter.string(from: object.endDate))"
    case .active:
      return "End In: \(displayDynamicTime(for: object.endDate.timeIntervalSince(Date())))"
    case .upcoming:
      return "Start In: \(displayDynamicTime(for: object.startDate.timeIntervalSince(Date())))"
    }
  }

  // MARK: Active objects
  var isActiveObjectsHidden: Bool { return self.activeObjects.isEmpty }
  var numberActiveObjects: Int { return self.activeObjects.count }
  func activeObject(at row: Int) -> IEOObject {
    return self.activeObjects[row]
  }

  // MARK: Upcoming Objects
  var isUpcomingObjectsHidden: Bool { return self.upcomingObjects.isEmpty }
  var numberUpcomingObjects: Int { return self.upcomingObjects.count }
  func upcomingObject(at row: Int) -> IEOObject {
    return self.upcomingObjects[row]
  }

  // MARK: Upcoming Objects
  var isPastObjectsHidden: Bool { return self.pastObjects.isEmpty }
  var numberPastObjects: Int { return self.pastObjects.count }
  func pastObject(at row: Int) -> IEOObject {
    return self.pastObjects[row]
  }

  var numberSections: Int {
    return self.dataSet.count
  }

  func numberRows(for section: Int) -> Int {
    return self.dataSet[section].count
  }

  func objects(for section: Int) -> [IEOObject] {
    return self.dataSet[section]
  }

  func headerTitle(for section: Int) -> String {
    return self.titles[section]
  }

  func object(for row: Int, in section: Int) -> IEOObject {
    return self.dataSet[section][row]
  }
}
