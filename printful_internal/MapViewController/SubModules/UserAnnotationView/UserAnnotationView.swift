//
//  UserAnnotationView.swift
//  printful_internal
//
//  Created by Eugene Mokhan on 08/04/2023.
//

import Foundation
import MapKit
import Kingfisher

class UserAnnotationView: MKAnnotationView {

    private enum Constants {
        static let bgImageColor = UIColor.systemPurple.withAlphaComponent(0.9)
        static let bgImage = UIImage(systemName: "person.circle")
        static let imageViewSize = CGSize(width: 30.0, height: 30.0)
        static let stackViewSpacing: CGFloat = 2.0
        static let animationDuration: TimeInterval = 0.3
        static let titleFont = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        static let descriptionFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
    }

    override var annotation: MKAnnotation? {
        didSet {
            updateItems()
        }
    }

    
    // MARK: - Private property

    private let bgImageView = UIImageView()
    private let imageView = UIImageView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    // MARK: - Init

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupItems()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupItems()
    }

    // MARK: - LifeCycle

    override func layoutSubviews() {
        super.layoutSubviews()
        bgImageView.layer.cornerRadius = bgImageView.bounds.width / 2.0
    }

    // MARK: - Public methods
    
    func updateItems() {
        guard let userAnnotation = annotation as? UserAnnotation else { return }

        canShowCallout = true

        titleLabel.text = userAnnotation.titleText
        updateImageView(with: userAnnotation.imageLink)
        updateDescriptionLabel(with: userAnnotation.coordinate)
    }
}

// MARK: - Private

private extension UserAnnotationView {
    func setupItems() {
        setupBGImageView()
        setupImageView()
        setupStackView()
        setupTitleLabel()
        setupDescriptionLabel()
    }

    func setupBGImageView() {
        addSubview(bgImageView)
        bgImageView.image = Constants.bgImage
        bgImageView.tintColor = Constants.bgImageColor
        bgImageView.contentMode = .scaleAspectFit
        bgImageView.bounds = CGRect(origin: .zero, size: Constants.imageViewSize)
    }

    func setupImageView() {
        imageView.bounds = CGRect(origin: .zero, size: Constants.imageViewSize)
        leftCalloutAccessoryView = imageView
    }

    func updateImageView(with imageLink: String?) {
        guard let imageLink = imageLink, let url = URL(string: imageLink) else { return }
        
        imageView.kf.setImage(with: url)
    }

    func setupStackView() {
        stackView.spacing = Constants.stackViewSpacing
        stackView.axis = .vertical
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        detailCalloutAccessoryView = stackView
    }

    func setupTitleLabel() {
        titleLabel.font = Constants.titleFont
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    func setupDescriptionLabel() {
        descriptionLabel.font = Constants.descriptionFont
        descriptionLabel.textColor = .tertiaryLabel
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    func updateDescriptionLabel(with coordinate: CLLocationCoordinate2D) {
        descriptionLabel.numberOfLines = .zero
        AddressesHelper.getAddressFrom(coordinate: coordinate) { [weak self] result in
            switch result {
            case .failure(_):
                self?.descriptionLabel.isHidden = true
            case .success(let address):
                UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
                    self?.descriptionLabel.text = address
                    self?.layoutIfNeeded()
                }
            }
        }
    }
}
