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

        /*  ------------------------ *\
         *      LANGUAGE & TEXT
        \*  ------------------------ */
        self.navigationItem.title = NSLocalizedString("statisticsTitle", comment: "")
        distanceTab.title = NSLocalizedString("distanceTitle", comment: "")
        caloriesTab.title = NSLocalizedString("caloriesTitle", comment: "")
        totalWheelsLabel.text = NSLocalizedString("totalWheelsTitle", comment: "")
        let user = User.getUser()
        totalWheels.text = String(user.wheelRotation!)
        
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
        
        let today = Date()
        let calendar = Calendar.current
        let weekDay = Calendar.current.component(.weekday, from: today)
        
        var tmpWeeks = [[Date]]()
        
        var mondaysDate: Date {
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        }
        
        // if current day = monday, append 5 weeks, else only 4 weeks!
        var weekCount : Int {
            if weekDay == 1 {
                return 4
            } else {
                return 3
            }
        }
        
        for menuItem in 0...weekCount {
            let startDay = calendar.date(byAdding: .day, value: (-7*menuItem), to: mondaysDate)!
            let endDay = calendar.date(byAdding: .day, value: 6, to: startDay)!
            tmpWeeks.append([startDay, endDay])
        }
        tmpWeeks = tmpWeeks.reversed()
        
        var weeks = [MenuItemView]()
        for week in tmpWeeks {
            let dateForm = DateFormatter()
            dateForm.dateFormat = "MMMM"
            var title = ""
            // same month or not?
            if dateForm.string(from: week[0]) == dateForm.string(from: week[1]) {
                // JUNI 17-24
                dateForm.dateFormat = "MMMM dd"
                title = dateForm.string(from: week[0])+"-"
                dateForm.dateFormat = "dd"
                title += dateForm.string(from: week[1])
            } else {
                // FEB 30 - MÄR 6
                dateForm.dateFormat = "MMM dd"
                title = "\(dateForm.string(from: week[0])) - \(dateForm.string(from: week[1]))"
            }
            weeks.append(MenuItemView(title: title.uppercased(), font: weeksFont))
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
    
        let options = PagingMenuOptions(view.bounds.width * 0.375, height: CGFloat(67.0), weeks: weeks)
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.setup(options)
        
        
        /*  ------------------------ *\
         *      DATE FIELDS (able to consider german or english dates (-: )
        \*  ------------------------ */
        let fieldForm = DateFormatter()
        fieldForm.dateFormat = "eee"
        monL.text = fieldForm.string(from: mondaysDate).uppercased()
        tueL.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 1, to: mondaysDate)!).uppercased()
        wedL.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 2, to: mondaysDate)!).uppercased()
        thuL.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 3, to: mondaysDate)!).uppercased()
        friL.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 4, to: mondaysDate)!).uppercased()
        satL.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 5, to: mondaysDate)!).uppercased()
        sunL.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 6, to: mondaysDate)!).uppercased()
        fieldForm.dateFormat = "d"
        monD.text = fieldForm.string(from: mondaysDate)
        tueD.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 1, to: mondaysDate)!)
        wedD.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 2, to: mondaysDate)!)
        thuD.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 3, to: mondaysDate)!)
        friD.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 4, to: mondaysDate)!)
        satD.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 5, to: mondaysDate)!)
        sunD.text = fieldForm.string(from: calendar.date(byAdding: .day, value: 6, to: mondaysDate)!)
        
        /*  ------------------------ *\
         *      CHART
        \*  ------------------------ */
        chartView.animate(yAxisDuration: 0.7, easingOption: ChartEasingOption.easeOutQuart)
        let bar = UIColor(red: 192/255.0, green: 57/255.0, blue: 43/255.0, alpha: 1)
        let bg = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        let gre = UIColor(red: 39/255.0, green: 174/255.0, blue: 96/255.0, alpha: 1)
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
        chartView.extraBottomOffset = 20
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
        
        // Data
        var dataEntries: [BarChartDataEntry] = []
        let data = [[1,19], [2,4], [3,0], [4,42], [5,17], [6,20], [7,1]]
        for i in 0..<data.count {
            let dataEntry = BarChartDataEntry(x: Double(data[i][0]), y: Double(data[i][1]))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Visitor count")
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
        chartView.invalidateIntrinsicContentSize()
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        shadowImageView?.isHidden = false
    }
    
    func distancePressed() {
        
    }
    
    func caloriesPressed() {
        
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
