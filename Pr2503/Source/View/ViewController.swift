import UIKit

class ViewController: UIViewController {
    
    //MARK: - Outlets

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bruteButton: UIButton!
    
    //MARK: - Properties
    
    lazy var password = ""
    var queue = DispatchQueue(label: "Brute", qos: .userInitiated)
    var isBlack: Bool = false {
        didSet {
            view.backgroundColor = isBlack ? .black : .white
            self.passwordLabel.textColor = isBlack ? .white : .black
            self.passwordTextField.textColor = isBlack ? .white : .black
            self.passwordTextField.backgroundColor = isBlack ? .gray : .white
            self.passwordTextField.tintColor = isBlack ? .black : .white
            self.indicator.color = isBlack ? .white : .black
        }
    }
    
    //MARK: - Actions
    
    @IBAction func onBut(_ sender: Any) {
        isBlack.toggle()
    }
    
    
    @IBAction func bruteAction(_ sender: Any) {
        prepareForBrute()
        let brutePassword = passwordGenerator()
        passwordTextField.text = brutePassword
        let brute = DispatchWorkItem {
            self.bruteForce(passwordToUnlock: brutePassword)
        }
        queue.async(execute: brute)
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.hidesWhenStopped = true
    }
    
    //MARK: - Funcs
    
    func passwordGenerator() -> String {
        let char = String().printable.map { String($0) }
        
        for _ in 0 ..< 3 {
            password += char.randomElement() ?? ""
        }
        
        return password
    }
    
    func prepareForBrute() {
        password = ""
        passwordLabel.text = "Ваш пароль..."
        passwordTextField.isSecureTextEntry = true
        bruteButton.isEnabled = false
        indicator.startAnimating()
    }
    
    func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }

        var password = ""

        // Will strangely ends at 0000 instead of ~~~
        while password != passwordToUnlock { // Increase MAXIMUM_PASSWORD_SIZE value for more
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)

            print(password)
        }
        
        DispatchQueue.main.async {
            self.passwordTextField.isSecureTextEntry = false
            self.passwordLabel.text = self.passwordTextField.text
            self.indicator.stopAnimating()
            self.bruteButton.isEnabled = true
        }
        
        print(password)
    }

    func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }

    func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index])
                                   : Character("")
    }

    func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var str: String = string

        if str.count <= 0 {
            str.append(characterAt(index: 0, array))
        }
        else {
            str.replace(at: str.count - 1,
                        with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))

            if indexOf(character: str.last!, array) == 0 {
                str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
            }
        }

        return str
    }

}



