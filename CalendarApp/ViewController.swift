//
//  ViewController.swift
//  CalendarApp
//
//  Created by 矢野涼 on 2020-04-26.
//  Copyright © 2020 Ryo Yano. All rights reserved.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import Photos

class ViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var backImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        calendar.dataSource = self
        
        PHPhotoLibrary.requestAuthorization{ (status) in
            
            switch(status){
                
            case .authorized:
                print("許可されています")
            case .denied:
                print("拒否されています")
            case .notDetermined:
                print("notDetermined")
            case .restricted:
                print("restricted")
                
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate let gregorian:Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
//    祝日判定を行い結果を返すメソッド
    func judgedHoliday(_ date :Date) ->Bool{
//        祝日判定用のカレンダーのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
//        祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
//        CalculateCalendarLogic()：祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()
        
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
        
    }
//    date型 -> 年月日をIntで取得
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
        
    }
//    曜日判定(日曜日１〜土曜日７)
    func getWeekIdx(_ date:Date)->Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    
//    土日や祝日の文字の色を変える
    func calendar(_ calendar:FSCalendar,appearance:FSCalendarAppearance,titleDefaulColorFor date:Date) ->UIColor?{
//        祝日を判定する
        if self.judgedHoliday(date){
            return UIColor.red
        }
//        土日判定を行う(土曜は青、日曜は赤)
        let weekday = self.getWeekIdx(date)
        if weekday == 1{
//            日曜日
            return UIColor.red
        }else{
            return UIColor.blue
        }
        return nil
    }
    @IBAction func openAlbum(_ sender: Any) {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            present(cameraPicker,animated: true,completion: nil)
        }else{
            print("エラーです")
//            アラートを出す
        }
    }
//    アルバムから画像が選択された時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage{
            backImageView.image = pickedImage
//            写真の保存
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, nil, nil)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

