import UIKit

class ViewController: UIViewController, UITableViewDelegate/*, UITableViewDataSource*/ {

	var FilmsData: FilmEntities?

	@IBOutlet weak var progresss: UIActivityIndicatorView!
	@IBOutlet weak var emptyNote: UILabel!
	@IBOutlet weak var FilmsTable: UITableView!
	@IBOutlet weak var searchBar: UISearchBar!

	var FilmDetailView: FilmEntityDetails?

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let filmBasicData = FilmsData!.Search[indexPath.row]
		let key = filmBasicData.imdbID

		let filmExtendedData = FilmsData?.extended?[key]

		FilmDetailView?.detailsText.text =
		"""
		Title: \(filmExtendedData?.Title ?? filmBasicData.Title)

		Plot: \(filmExtendedData?.Plot ?? "-")

		Actors: \(filmExtendedData?.Actors ?? "-")

		Awards: \(filmExtendedData?.Awards ?? "-")

		Country: \(filmExtendedData?.Country ?? "-")

		Director: \(filmExtendedData?.Director ?? "-")

		Genre: \(filmExtendedData?.Genre ?? "-")

		Language: \(filmExtendedData?.Language ?? "-")

		Production: \(filmExtendedData?.Production ?? "-")

		Rated: \(filmExtendedData?.Rated ?? "-")

		Released: \(filmExtendedData?.Released ?? "-")

		Runtime: \(filmExtendedData?.Runtime ?? "-")

		Writer: \(filmExtendedData?.Writer ?? "-")

		Year: \(filmExtendedData?.Year ?? filmBasicData.Year)

		imdb ID: \(filmExtendedData?.imdbID ?? "-")

		imdb Rating: \(filmExtendedData?.imdbRating ?? "-")

		imdb Votes: \(filmExtendedData?.imdbVotes ?? "-")
		"""

		// скачать картинку
		if let path = Bundle.main.path(forResource: "Posters/\(filmBasicData.Poster)", ofType: "") {
			let contents = FileManager.default.contents(atPath: path)
			FilmDetailView?.poster.image = UIImage(data: contents!)
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		FilmDetailView = segue.destination.view as? FilmEntityDetails
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		searchBar.delegate = self

		FilmsTable.delegate = self as UITableViewDelegate
	}

}

extension ViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.count >= 3 {
			DispatchQueue.global().sync {
				DispatchQueue.main.async { self.progresss.startAnimating() }
				if let data = try? Data(contentsOf: URL(string: "http://www.omdbapi.com/?apikey=7e9fe69e&s=\(searchText.replacingOccurrences(of: " ", with: "+"))&page=1")!) {
					if let filmsData = try? JSONDecoder().decode(FilmEntities.self, from: data) {
						self.FilmsData = filmsData

						DispatchQueue.global().async {
							filmsData.extended = [:]
							for i in 0..<filmsData.Search.count {
								let res = filmsData.Search[i].imdbID

								if let data = try? Data(contentsOf: URL(string: "http://www.omdbapi.com/?apikey=7e9fe69e&i=\(res)")!) {
									filmsData.extended![res] = try? JSONDecoder().decode(FilmEntityExtended.self, from: data)
								} else {
									filmsData.extended![res] = (FilmEntityExtended())
								}
							}

							DispatchQueue.main.async { self.progresss.stopAnimating() }
						}

						self.FilmsTable.dataSource = self.FilmsData
						self.emptyNote.isHidden = self.FilmsData?.Search.count != 0
						self.FilmsTable.reloadData()
					}
				} else {
					self.searchBarCancelButtonClicked(searchBar)
				}
			}
		} else {
			searchBarCancelButtonClicked(searchBar)
		}
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		FilmsData = nil
		FilmsTable.dataSource = FilmsData
		emptyNote.isHidden = FilmsData != nil && FilmsData?.Search.count != 0
		FilmsTable.reloadData()
		progresss.stopAnimating()
	}
}

