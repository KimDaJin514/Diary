//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 김다진 on 2023/03/23.
//

import UIKit

// 작성한 일기를 메인 화면에 전달하기 위한 Delegate
protocol WriteDiaryViewDelegate: AnyObject {
    func didSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date? //datePicker에서 선택된 날짜가 저장될 변수
    
    weak var delegate: WriteDiaryViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
        
        // 처음 진입 시 등록버튼 비활성화
        self.confirmButton.isEnabled = false
    }

    // 내용 입력 textView 테두리 만들어주기
    private func configureContentsTextView(){
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        // layer 컬러를 지정할 땐, uiColor가 아닌 cgColor를 설정해야 함
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        
        // action: 선택되고 나서의 액션 정의
        // for: 어떤 이벤트가 일어났을 때 action에 정의된 함수를 실행시킬 건지
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        
        self.datePicker.locale = Locale(identifier: "ko-KR")
        // 날짜 textfield를 클릭했을 때 키보드가 아니라 데이터 피커가 뜨도록
        self.dateTextField.inputView = self.datePicker
    }
    
    private func configureInputField(){
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func tabConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return }
        
        // 작성된 일기 메인에 전달
        let diary = Diary(title: title, contents: contents, date: date, isStar: false)
        self.delegate?.didSelectRegister(diary: diary)
        self.navigationController?.popViewController(animated: true)
    }
 
    // 날짜 선택했을 때 액션
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        // 형식맞추기
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy년 MM월 dd일(EEEEE)"   //EEEEE-> 요일을 한 글자만 표현
        formmater.locale = Locale(identifier: "ko_KR")
        
        // 데이터 담기
        self.diaryDate = datePicker.date
        self.dateTextField.text = formmater.string(from: datePicker.date)
        
        // datepicker는 텍스트를 입력받는 구조가 아니기 때문에 아래와 같이 해줘야 변화를 감지할 수 있음
        self.dateTextField.sendActions(for: .editingChanged)
    }
    
    // 제목 텍스트필드 바뀌었을 때 등록 버튼 활성화 체크 위해 호출될 셀렉터
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    // 날짜 텍스트필드 바뀌었을 때 등록 버튼 활성화 체크 위해 호출될 셀렉터
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    // 키보드 올라왔을 때, 빈 화면 터치하면 키보드 내려가도록
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // 등록버튼의 활성화 여부를 다루는 함수 (텍스트 필드에 빈값 없는지)
    private func validateInputField(){
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) &&
        !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty
        
    }
}


extension WriteDiaryViewController: UITableViewDelegate {
    // textViewDidChange : textView에 text가 입력될 때마다 호출
    func textViewDidChange(_ textView: UITableView) {
        // 텍스트가 입력될 때마다 등록 버튼 활성화 여부 체크
        self.validateInputField()
    }
}
