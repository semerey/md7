import UIKit

struct ImageURL: Decodable {
	let webformatURL: String
}

struct ImagesResult: Decodable {
	let hits: [ImageURL]
}

class CollectionViewController: UIViewController, UICollectionViewDelegate {

	@IBOutlet weak var PicturesCollectionView: UICollectionView!
	@IBOutlet weak var progress: UIActivityIndicatorView!

	var PictureSource: CollectionViewDataSource?

	override func viewDidLoad() {
		super.viewDidLoad()

		PictureSource = CollectionViewDataSource()
		PictureSource!.Images = []

		PicturesCollectionView.delegate = self
		PicturesCollectionView.dataSource = PictureSource

		DispatchQueue.global().async {
			if let data = try? Data(contentsOf: URL(string: "https://pixabay.com/api/?key=19193969-87191e5db266905fe8936d565&q=red+cars&image_type=photo&per_page=21")!) {
				let imageResults = try! JSONDecoder().decode(ImagesResult.self, from: data)

				DispatchQueue.global().async {
					for imageUrl in imageResults.hits {
						DispatchQueue.global().async {
							if let data = try? Data(contentsOf: URL(string: imageUrl.webformatURL)!) {
								self.PictureSource!.Images!.append(UIImage(data: data)!)
							}

							DispatchQueue.main.async {
								self.PicturesCollectionView.reloadData()
							}
						}
					}
				}

				DispatchQueue.main.async {
					self.progress.stopAnimating()
				}
			}
		}

	}
	
}
