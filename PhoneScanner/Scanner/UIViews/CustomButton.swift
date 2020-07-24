
import UIKit

class CustomButton: UIView {

    @IBInspectable var image: UIImage? {
        set {
            self.imageView.image = newValue
        }
        get {
            self.imageView.image
        }
    }

    @IBInspectable var text: String? {
        set {
            self.textView.text = newValue
        }
        get {
            textView.text
        }
    }

    private var imageView = UIImageView()
    private var textView = UILabel()
    private var stackView = UIStackView()

    private var imageViewConstraints: CGFloat = 50

    override func layoutSubviews() {
        self.setupImageView()
        self.setupTextView()
        self.setupStackView()
        self.setupConstraints()
        self.setupView()
    }

    private func setupImageView() {
        self.imageView.widthAnchor.constraint(equalToConstant: imageViewConstraints).isActive = true
        self.imageView.heightAnchor.constraint(equalToConstant: imageViewConstraints).isActive = true
        self.imageView.tintColor = .white
        self.imageView.contentMode = .center
        self.imageView.backgroundColor = .clear
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = imageViewConstraints/2
        self.imageView.layer.borderWidth = 0.5
        self.imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
    }

    private func setupTextView() {
        self.textView.font = self.textView.font.withSize(14)
        self.textView.textColor = UIColor.white.withAlphaComponent(0.6)
    }

    private func setupStackView() {
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.addArrangedSubview(self.imageView)
        stackView.addArrangedSubview(self.textView)
        stackView.spacing = 8
    }

    private func setupConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.stackView)
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    }

    private func setupView() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let _ = touch.location(in: self)
            // do something with your currentPoint
            self.scaleDown()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.scaleUp()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.scaleUp()
    }

    private func scaleDown() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }
    }

    private func scaleUp() {
        UIView.animate(withDuration: 0.2) {
           self.transform = .identity
        }
    }

}
