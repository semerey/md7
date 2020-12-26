import UIKit


struct FilmEntity: Decodable {

	var Title: String
	var Year: String
	var imdbID: String
	var Poster: String

	static func ==(lhs: FilmEntity, rhs: FilmEntity) -> Bool {
		return lhs.Title == rhs.Title
	}
}

struct FilmEntityExtended: Decodable {

	var Title: String?
	var Year: String?
	var Rated: String?
	var Released: String?
	var Runtime: String?
	var Genre: String?
	var Director: String?
	var Writer: String?
	var Actors: String?
	var Plot: String?
	var Language: String?
	var Country: String?
	var Awards: String?
	var Poster: String?
	var imdbRating: String?
	var imdbVotes: String?
	var imdbID: String?
	var Production: String?
}

class FilmEntities: NSObject, Decodable, UITableViewDataSource {
	var Search: [FilmEntity]
	var extended: [String: FilmEntityExtended]?

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.Search.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FilmEntityCell", for: indexPath) as! FilmEntityCell
		DispatchQueue.global().async {
			if let data = try? Data(contentsOf: URL(string: self.Search[indexPath.row].Poster)!) {
				DispatchQueue.main.async { cell.filmImage.image = UIImage(data: data) }
			}
		}
		cell.filmTitle.text = Search[indexPath.row].Title
		cell.year.text = Search[indexPath.row].Year
		return cell
	}

}
