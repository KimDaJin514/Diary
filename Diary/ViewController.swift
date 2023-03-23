//
//  ViewController.swift
//  Diary
//
//  Created by 김다진 on 2023/03/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var diaryList = [Diary]() {
        // diaryList의 변경이 일어날 때마다 새로 저장함
        didSet {
            self.saveDiaryList()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadDiaryList()
        print("일기 수 : \(self.diaryList.count)")
    }
    
    private func configureCollectionView(){
        self.collectionView.collectionViewLayout = UICollectionViewLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            writeDiaryViewController.delegate = self
        }
    }
    

    // 로컬 저장소에 저장
    private func saveDiaryList(){
        let date = self.diaryList.map {
            [
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }
        
        let userDefualts = UserDefaults.standard
        userDefualts.set(date, forKey: "diaryList")
    }
    
    // 로컬 저장소에 저장된 값 가져오기
    private func loadDiaryList(){
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }   // 딕셔너리로 타입캐스팅
        
        // 가져온 데이터를 다이어리 리스트에 넣어주기
        self.diaryList = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            
            return Diary(title: title, contents: contents, date: date, isStar: isStar)
        }
        
        // 일기 최신순으로 정렬
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    private func dateToString(date: Date) -> String{
        let formmatter = DateFormatter()
        formmatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formmatter.locale = Locale(identifier: "ko_KR")
        return formmatter.string(from: date)
    }
}

// data source: collection view로 보여지는 컨텐츠를 관리하는 객체
extension ViewController: UICollectionViewDataSource {
    // cell에 표시할 섹션 개수 (다이어리 리스트 개수)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("???? \(self.diaryList.count)")
        return self.diaryList.count
    }
    
    // 컬렉션 뷰 지정된 위치에 표시할 셀을 요청하는 메서드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 스토리보드에서 만든 cell을 가져옴
        // DiaryCell 로 다운캐스팅하는 데 실패하면 빈 셀 반환
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else {
            print("nil!!!")
            return UICollectionViewCell() }
        
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        return cell
    }
}

// collectionView의 레이아웃 설정
extension ViewController: UICollectionViewDelegateFlowLayout {

    // cell 의 size 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
}

// 일기작성 화면에서 등록버튼 누르면 실행됨
extension ViewController: WriteDiaryViewDelegate {
    func didSelectRegister(diary: Diary) {
        self.diaryList.append(diary)
        
        // 일기 최신순으로 정렬
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        print("diary : \(diaryList)")
        self.collectionView.reloadData()
    }
}
