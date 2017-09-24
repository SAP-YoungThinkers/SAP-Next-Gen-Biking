//
//  StatisticsViewController.swift
//  MRNBike
//
//  Created by Huyen Nguyen on 28.08.17.
//
//

import UIKit
import PagingMenuController
import Charts

class StatisticsViewController: UIViewController, UITabBarDelegate {
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var distanceTab: UITabBarItem!
    @IBOutlet weak var caloriesTab: UITabBarItem!
    @IBOutlet weak var totalWheels: UILabel!
    @IBOutlet weak var totalWheelsLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var chartView: BarChartView!
    
    /*  ------------------------ *\
     *      DATE FIELDS
    \*  ------------------------ */
    @IBOutlet weak var monL: UILabel!
    @IBOutlet weak var tueL: UILabel!
    @IBOutlet weak var wedL: UILabel!
    @IBOutlet weak var thuL: UILabel!
    @IBOutlet weak var friL: UILabel!
    @IBOutlet weak var satL: UILabel!
    @IBOutlet weak var sunL: UILabel!
    // Dates
    @IBOutlet weak var monD: UILabel!
    @IBOutlet weak var tueD: UILabel!
    @IBOutlet weak var wedD: UILabel!
    @IBOutlet weak var thuD: UILabel!
    @IBOutlet weak var friD: UILabel!
    @IBOutlet weak var satD: UILabel!
    @IBOutlet weak var sunD: UILabel!
    
    
    private var tempPlaceholder : UIView?
    private let primaryColor = UIColor(red: (192/255.0), green: (57/255.0), blue: (43/255.0), alpha: 1.0)
    private var shadowImageView: UIImageView?
    private var userRoutesKeys = [Int]()
    private var returnDates = [Date]()
    private var weekKeys : [[Int]] = Array(repeating: Array(repeating: -1, count: 7), count: 5) // weekKey[week][day] = position in json array
    private var weekIntervals = [[Date]]()
    private var currentWeekStart : Date!
    private var stats : [String: Any]? = nil
    private var pagingMenuController : PagingMenuController?
    private var selectedUnit = "distance"
    
    // Menu handling from outside view
    @IBAction func swipedLeft(_ sender: UISwipeGestureRecognizer) {
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.move(toPage: (pagingMenuController.currentPage+1), animated: true)
    }
    @IBAction func swipedRight(_ sender: UISwipeGestureRecognizer) {
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.move(toPage: max(0, pagingMenuController.currentPage-1), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pagingMenuController = self.childViewControllers.first as? PagingMenuController
        
        /*  ------------------------ *\
         *      WEEKS SETUP
        \*  ------------------------ */
        let weeksFont = UIFont(name: "Montserrat-Light", size: 18) ?? UIFont.systemFont(ofSize: 13)
        struct MenuItemView : MenuItemViewCustomizable {
            var title = ""
            var displayMode : MenuItemDisplayMode {
                return .text(title: MenuItemText.init(text: self.title, color: UIColor(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 0.5), selectedColor: UIColor(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1), font: font, selectedFont: font))
            }
            var font : UIFont
            init(title : String, font : UIFont) {
                self.title = title
                self.font = font
            }
        }
        
        // Today without time!
        let tmpToday = Date()
        let calendar = Calendar.current
        var dc = DateComponents()
        dc.year = calendar.component(.year, from: tmpToday)
        dc.month = calendar.component(.month, from: tmpToday)
        dc.day = calendar.component(.day, from: tmpToday)
        dc.timeZone = TimeZone(abbreviation: "GMT")
        
        let today = calendar.date(from: dc)!
        
        let weekDay = calendar.component(.weekday, from: today)
        
        var weekStartDay: Date {
            if Locale.current.identifier.contains("de_") {
                // German week starts with monday
                return calendar.date(byAdding: .day, value: ((-(weekDay-1))+1), to: today)!
            } else {
                // English week starts with sunday
                return calendar.date(byAdding: .day, value: (-(weekDay-1)), to: today)!
            }
        }
        
        currentWeekStart = weekStartDay
        
        // if current day = monday, append 5 weeks, else only 4 weeks!
        var weekCount : Int {
            if weekDay == 1 {
                return 4
            } else {
                return 3
            }
        }
        
        for menuItem in 0...weekCount {
            let startDay = calendar.date(byAdding: .day, value: (-7*menuItem), to: weekStartDay)!
            let endDay = calendar.date(byAdding: .day, value: 6, to: startDay)!
            weekIntervals.append([startDay, endDay])
        }
        weekIntervals = weekIntervals.reversed()
        
        var weekViews = [MenuItemView]()
        for week in weekIntervals {
            let dateForm = DateFormatter()
            dateForm.dateFormat = "MMMM"
            var title = ""
            // same month or not?
            if dateForm.string(from: week[0]) == dateForm.string(from: week[1]) {
                // JUNI 17-24
                // adaptive
                switch UIScreen.main.bounds.width {
                case 0...340:
                    dateForm.dateFormat = "MMM dd"
                    break
                default:
                    dateForm.dateFormat = "MMMM dd"
                }
                title = dateForm.string(from: week[0])+"-"
                dateForm.dateFormat = "dd"
                title += dateForm.string(from: week[1])
            } else {
                // FEB 30 - MÄR 6
                dateForm.dateFormat = "MMM dd"
                title = "\(dateForm.string(from: week[0])) - \(dateForm.string(from: week[1]))"
            }
            weekViews.append(MenuItemView(title: title.uppercased(), font: weeksFont))
            
        }
        
        
        /*  ------------------------ *\
         *      LOAD STATISTICS
         *      UPDATE DATA
        \*  ------------------------ */
        
        userRoutesKeys.removeAll()
        if let keys = KeychainService.loadIDs() {
            userRoutesKeys.append(contentsOf: keys)
            userRoutesKeys.sort(by: >)
        }
        
        if(userRoutesKeys.count != 0) {
            
            let requestIDs: [String: Any] = ["routeIds": userRoutesKeys]
            let activityAlert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
            present(activityAlert, animated: false, completion: nil)
            
            do {
                
                let jsonData = try JSONSerialization.data(withJSONObject: requestIDs, options: [])
                
                ClientService.getRouteInfos(routeKeys: jsonData) { (stats, error) in
                    
                    if error == nil {
                        activityAlert.dismiss(animated: false, completion: nil)
                        
                        // extract dates from json
                        self.stats = stats
                        let rDF = DateFormatter()
                        rDF.locale = Locale(identifier: "en_US")
                        rDF.timeZone = TimeZone(abbreviation: "GMT")
                        rDF.dateFormat = "eee MMM dd yyyy"
                        for date in (self.stats!["days"]! as! [String]) {
                            self.returnDates.append(rDF.date(from: date)!)
                        }
                        
                        self.statisticsDataBase()
                        
                        
                    } else {
                        activityAlert.dismiss(animated: false, completion: nil)
                        self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                    }
                }
            } catch {
                activityAlert.dismiss(animated: false, completion: nil)
                self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
            }
        
        }

    
        /*  ------------------------ *\
         *      LANGUAGE & TEXT
        \*  ------------------------ */
        self.navigationItem.title = NSLocalizedString("statisticsTitle", comment: "")
        distanceTab.title = NSLocalizedString("distanceTitle", comment: "")
        caloriesTab.title = NSLocalizedString("caloriesTitle", comment: "")
        totalWheelsLabel.text = NSLocalizedString("totalWheelsTitle", comment: "")
        let user = User.getUser()
        if let rotations = user.wheelRotation {
            totalWheels.text = String(rotations)
        }
        
        /*  ------------------------ *\
         *      DESIGN
        \*  ------------------------ */
        tabBar.delegate = self
        tabBar.selectedItem = distanceTab
        tabBar.shadowImage = UIImage()
        tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: primaryColor, size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count), height: tabBar.frame.height), lineWidth: 3.0)
        tempPlaceholder = setupTabBarSeparators()
        self.childViewControllers.first!.view.backgroundColor = UIColor.clear
        
        // Set Font, Size for Items
        for item in tabBar.items! {
            item.setTitleTextAttributes([NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)], for: UIControlState.normal)
        }
        
        
        /*  ------------------------ *\
         *      SWIPE MENU
        \*  ------------------------ */
        struct MenuOptions: MenuViewCustomizable {
            var itemWidth : CGFloat
            var height : CGFloat
            var weeks : [MenuItemViewCustomizable]
            var itemsOptions: [MenuItemViewCustomizable] {
                return weeks
            }
            var focusMode : MenuFocusMode {
                return .none
            }
            var displayMode : MenuDisplayMode {
                return .standard(widthMode: MenuItemWidthMode.fixed(width: itemWidth), centerItem: true, scrollingMode: MenuScrollingMode.pagingEnabled)
            }
            var backgroundColor: UIColor = UIColor.clear
            var selectedBackgroundColor: UIColor = UIColor.clear
            init(_ width : CGFloat, height: CGFloat, weeks : [MenuItemViewCustomizable]) {
                self.itemWidth = width
                self.height = height
                self.weeks = weeks
            }
        }
        
        struct PagingMenuOptions: PagingMenuControllerCustomizable {
            var width : CGFloat
            var height : CGFloat
            var weeks : [MenuItemViewCustomizable]
            var componentType: ComponentType {
                return .menuView(menuOptions: MenuOptions(width, height: height, weeks : weeks))
            }
            var backgroundColor: UIColor = UIColor.clear
            var defaultPage: Int = 0
            init(_ width: CGFloat, height: CGFloat, weeks : [MenuItemViewCustomizable]) {
                self.width = width
                self.height = height
                self.weeks = weeks
                self.defaultPage = max(0,weeks.count-1)
            }
        }
    
        let options = PagingMenuOptions(view.bounds.width * 0.375, height: CGFloat(67.0), weeks: weekViews)
        pagingMenuController!.setup(options)
        
        pagingMenuController!.onMove = { state in
            switch state {
            case .didMoveItem(to: _, from: _):
                self.setChartData(currentPage: self.pagingMenuController!.currentPage)
                self.updateDateBar()
            default: break
            }
        }
        
        /*  ------------------------------------------------ *\
         *      DATE FIELDS
         *      (able to consider german or english dates)
        \*  ------------------------------------------------ */
        updateDateBar()
        
        /*  ------------------------ *\
         *      CHART
        \*  ------------------------ */
        chartView.animate(yAxisDuration: 0.7, easingOption: ChartEasingOption.easeOutQuart)
        chartView.chartDescription?.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.highlightFullBarEnabled = false
        chartView.backgroundColor = UIColor.clear
        chartView.highlightPerDragEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.drawBarShadowEnabled = true
        chartView.drawBordersEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.extraBottomOffset = 26
        let yr = chartView.rightAxis
        let yl = chartView.leftAxis
        let leg = chartView.legend
        let x = chartView.xAxis
        yl.drawZeroLineEnabled = false
        yr.drawZeroLineEnabled = false
        x.drawAxisLineEnabled = false
        chartView.fitBars = true
        leg.enabled = false
        yl.axisMinimum = 0
        yr.axisMinimum = 0
        yl.enabled = false
        yr.enabled = false
        x.labelPosition = XAxis.LabelPosition.bottom
        x.labelFont = UIFont(name: "Montserrat-Regular", size: 13) ?? UIFont.systemFont(ofSize: 15)
        
        setChartData(currentPage: pagingMenuController!.currentPage)
        
        if !(Reachability.isConnectedToNetwork()) {
            // no Internet connection
            self.present(UIAlertCreator.infoAlert(title: "", message: NSLocalizedString("ErrorNoInternetConnection", comment: "")), animated: true, completion: nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = 60
        self.tabBar.frame = tabFrame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(tabBar.selectedItem == distanceTab) {
            distancePressed()
        } else if (tabBar.selectedItem == caloriesTab){
            caloriesPressed()
        }
        
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = true
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(tabBar.selectedItem == distanceTab) {
            distancePressed()
        } else if (tabBar.selectedItem == caloriesTab){
            caloriesPressed()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        shadowImageView?.isHidden = false
    }
    
    func setChartData(currentPage: Int) {
        if userRoutesKeys.count != 0 {
            self.currentWeekStart = self.weekIntervals[currentPage][0]
            let z = self.weekKeys[currentPage]
            var statValues = Array(repeating: 0, count: 7)
            var labels = [""]
            if let stats = self.stats?[selectedUnit] as? [Int] {
                // stats not empty
                for i in 0...6 {
                    switch z[i] {
                    case let x where x >= 0:
                        statValues[i] = stats[x]
                        labels.append("\n\(stats[x])")
                    default:
                        // day not in statistics data base
                        labels.append("\n-")
                    }
                }
            }
            let x = chartView.xAxis
            x.valueFormatter = IndexAxisValueFormatter(values: labels)
            self.chart(withData: [[1, statValues[0]], [2, statValues[1]], [3, statValues[2]], [4, statValues[3]], [5, statValues[4]], [6, statValues[5]], [7, statValues[6]]])
        } else {
            // everything zero because of no routes
            let x = chartView.xAxis
            x.valueFormatter = IndexAxisValueFormatter(values: ["","\n-","\n-","\n-","\n-","\n-","\n-","\n-"])
            self.chart(withData: [[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]])
        }
    }
    
    func statisticsDataBase() {
        
        for (weekIndex, week) in weekIntervals.enumerated() {
            // restructure array with statistics per weeks
            let cal = Calendar.current
            for (dateKey, date) in returnDates.enumerated() {
                let dif = cal.dateComponents([.day], from: week[0], to: date).day!
                switch dif {
                case 0...6:
                    weekKeys[weekIndex][dif] = dateKey
                default:
                    break
                }
            }
        }
        
        setChartData(currentPage: self.pagingMenuController!.currentPage)
    }
    
    func chart(withData data : [[Int]]) {
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<data.count {
            let dataEntry = BarChartDataEntry(x: Double(data[i][0]), y: Double(data[i][1]))
            dataEntries.append(dataEntry)
        }
        let bar = UIColor(red: 192/255.0, green: 57/255.0, blue: 43/255.0, alpha: 1)
        let bg = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        let gre = UIColor(red: 39/255.0, green: 174/255.0, blue: 96/255.0, alpha: 1)
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "")
        chartDataSet.setColor(bar, alpha: 1)
        chartDataSet.barShadowColor = bg
        chartDataSet.drawValuesEnabled = false
        chartDataSet.highlightColor = gre
        chartDataSet.highlightAlpha = 1
        
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = (chartData.barWidth * 0.425)
        chartView.data = chartData
        
        // highlight maximum(s)
        var maxi = 0
        var maxKey = [Int]()
        var highlights = [Highlight]()
        for value in data {
            if value[1] > maxi {
                maxKey = [value[0]]
                maxi = value[1]
            } else if value[1] == maxi {
                maxKey.append(value[0])
            }
        }
        for key in maxKey {
            highlights.append(Highlight(x: Double(key), dataSetIndex: 0, stackIndex: 0))
        }
        chartView.highlightValues(highlights)
        
        // refresh
        chartView.notifyDataSetChanged()
        chartView.invalidateIntrinsicContentSize()
    }
    
    func updateDateBar() {
        let calendar = Calendar.current
        let fieldForm = DateFormatter()
        fieldForm.dateFormat = "eee"
        monL.text = fieldForm.string(from: currentWeekStart).uppercased()
        tueL.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 1, to: currentWeekStart)!).uppercased()
        wedL.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 2, to: currentWeekStart)!).uppercased()
        thuL.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 3, to: currentWeekStart)!).uppercased()
        friL.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 4, to: currentWeekStart)!).uppercased()
        satL.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 5, to: currentWeekStart)!).uppercased()
        sunL.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 6, to: currentWeekStart)!).uppercased()
        fieldForm.dateFormat = "d"
        monD.text = fieldForm.string(from: currentWeekStart)
        tueD.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 1, to: currentWeekStart)!)
        wedD.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 2, to: currentWeekStart)!)
        thuD.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 3, to: currentWeekStart)!)
        friD.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 4, to: currentWeekStart)!)
        satD.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 5, to: currentWeekStart)!)
        sunD.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 6, to: currentWeekStart)!)
    }
    
    func distancePressed() {
        selectedUnit = "distance"
        setChartData(currentPage: pagingMenuController!.currentPage)
    }
    
    func caloriesPressed() {
        selectedUnit = "calories"
        setChartData(currentPage: pagingMenuController!.currentPage)
    }
    
    func setupTabBarSeparators() -> UIView {
        let itemWidth = floor(self.tabBar.frame.width / CGFloat(self.tabBar.items!.count))
        let separatorWidth: CGFloat = 0.5
        let separator = UIView(frame: CGRect(x: itemWidth + 0.5 - CGFloat(separatorWidth / 2), y: 0, width: CGFloat(separatorWidth), height: self.tabBar.frame.height))
        separator.backgroundColor = UIColor(red: (170/255.0), green: (170/255.0), blue: (170/255.0), alpha: 1.0)
        self.tabBar.insertSubview(separator, at: 1)
        
        return separator
    }
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }

}
